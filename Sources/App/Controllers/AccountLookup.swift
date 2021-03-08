import EOSIO
import Metrics
import Vapor

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

final class AccountLookup {
    struct LookupParams: Content {
        var publicKey: PublicKey
        var includeTestnets: Bool = false
    }

    struct NetworkAccounts: Content {
        var network: String
        var chainId: String
        var accounts: [PermissionLevel]
    }

    let urlSession: URLSession

    init() {
        let config = URLSessionConfiguration.default
        config.httpMaximumConnectionsPerHost = 10
        urlSession = URLSession(configuration: config)
    }

    // fallback endoint
    private func historyLookup(req: Vapor.Request, publicKey: PublicKey, network: Network) -> EventLoopFuture<[PermissionLevel]> {
        let client = EOSIO.Client(address: network.nodeUrl, session: urlSession)
        let accounts = client.send(EOSIO.API.V1.History.GetKeyAccounts(publicKey), on: req.eventLoop).flatMap { res in
            res.accountNames.map { name in
                client.send(EOSIO.API.V1.Chain.GetAccount(name), on: req.eventLoop)
            }.flatten(on: req.eventLoop)
        }
        return accounts.map { accounts -> [PermissionLevel] in
            var rv: [PermissionLevel] = []
            for account in accounts {
                for permission in account.permissions {
                    if permission.requiredAuth.hasPermission(for: publicKey) {
                        rv.append(PermissionLevel(account.accountName, permission.permName))
                    }
                }
            }
            return rv
        }
    }

    // new chain endoint
    private func chainLookup(req: Vapor.Request, publicKey: PublicKey, network: Network) -> EventLoopFuture<[PermissionLevel]> {
        let client = EOSIO.Client(address: network.nodeUrl, session: urlSession)
        let accounts = client.send(EOSIO.API.V1.Chain.GetAccountsByAuthorizers(keys: [publicKey]), on: req.eventLoop)
        return accounts.map { response -> [PermissionLevel] in
            var rv: [PermissionLevel] = []
            for account in response.accounts {
                rv.append(PermissionLevel(account.accountName, account.permissionName))
            }
            return rv
        }
    }

    private func networkLookup(req: Vapor.Request, publicKey: PublicKey, network: Network) -> EventLoopFuture<[PermissionLevel]> {
        let start = Date.timeIntervalSinceReferenceDate
        let lookup: EventLoopFuture<[PermissionLevel]>
        if network.chainLookupSupport {
            lookup = chainLookup(req: req, publicKey: publicKey, network: network).flatMapError { error in
                if case let EOSIO.Client.Error.responseError(responseError) = error, responseError.code == 404 {
                    req.logger.debug("No chain lookup support on \(network), switching to history API")
                } else {
                    req.logger.warning(
                        "Chain lookup error on \(network): \(error), falling back to history API",
                        metadata: ["network": "\(network)"]
                    )
                    Metrics.Counter(
                        label: "account_lookup_fallbacks",
                        dimensions: [("network", "\(network)")]
                    ).increment()
                }
                return self.historyLookup(req: req, publicKey: publicKey, network: network)
            }
        } else {
            lookup = historyLookup(req: req, publicKey: publicKey, network: network)
        }
        return lookup.always { _ in
            Metrics.Timer(
                label: "account_lookup_duration_seconds",
                dimensions: [("network", "\(network)")],
                preferredDisplayUnit: .seconds
            ).record(Date.timeIntervalSinceReferenceDate - start)
        }
    }

    func lookup(req: Vapor.Request) throws -> EventLoopFuture<[NetworkAccounts]> {
        guard let publicKey = req.parameters.get("key", as: PublicKey.self) else {
            throw Abort(.badRequest, reason: "Invalid public key")
        }

        let includeTestnets = (try? req.query.get(Bool.self, at: "includeTestnets")) ?? false
        let networks = includeTestnets ? Network.allNetworks : Network.mainNetworks

        req.logger[metadataKey: "public-key"] = "\(publicKey)"

        let rv = networks.map { network in
            self.networkLookup(req: req, publicKey: publicKey, network: network)
                // exclude networks with no found accounts
                .map { accounts -> [PermissionLevel]? in
                    accounts.isEmpty ? nil : accounts
                }
                // don't fail request on node errors, just log
                .recover { error in
                    req.logger.warning(
                        "Lookup error on \(network): \(error)",
                        metadata: ["network": "\(network)"]
                    )
                    Metrics.Counter(
                        label: "account_lookup_failures",
                        dimensions: [("network", "\(network)")]
                    ).increment()
                    return nil
                }.optionalMap { accounts in
                    NetworkAccounts(network: network.name, chainId: String(network.chainId), accounts: accounts)
                }
        }.flatten(on: req.eventLoop).mapEachCompact { $0 }

        rv.whenSuccess { networkAccounts in
            let totalAccounts = networkAccounts.reduce(0) { $0 + $1.accounts.count }
            req.logger.info("Found \(totalAccounts) auths(s) across \(networkAccounts.count) network(s)")
        }

        return rv
    }
}
