import EOSIO
import NIO

extension EOSIO.Client {
    func send<T: EOSIO.Request>(_ request: T, on eventLoop: EventLoop) -> EventLoopFuture<T.Response> {
        let promise = eventLoop.makePromise(of: T.Response.self)
        send(request) { result in
            switch result {
            case let .failure(error):
                promise.fail(error)
            case let .success(value):
                promise.succeed(value)
            }
        }
        return promise.futureResult
    }
}
