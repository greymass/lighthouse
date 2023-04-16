import EOSIO
import Foundation

enum Network: String, Codable, Hashable, Equatable {
    case eos
    case fio
    case fioTestnet
    case jungle3
    case jungle4
    case telos
    case telosTestnet
    case wax
    case waxTestnet
    case proton
    case libre
    case libreTestnet
    case ux

    var name: String {
        switch self {
        case .eos:
            return "EOS"
        case .fio:
            return "FIO"
        case .fioTestnet:
            return "FIO (Testnet)"
        case .jungle3:
            return "Jungle 3 (Testnet)"
        case .jungle4:
            return "Jungle 4 (Testnet)"
        case .proton:
            return "PROTON"
        case .telos:
            return "Telos"
        case .telosTestnet:
            return "Telos (Testnet)"
        case .wax:
            return "WAX"
        case .waxTestnet:
            return "WAX (Testnet)"
        case .libre:
            return "Libre"
        case .libreTestnet:
            return "Libre (Testnet)"
        case .ux:
            return "UX"
        }
    }

    var chainId: ChainId {
        switch self {
        case .eos:
            return "aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906"
        case .fio:
            return "21dcae42c0182200e93f954a074011f9048a7624c6fe81d3c9541a614a88bd1c"
        case .fioTestnet:
            return "b20901380af44ef59c5918439a1f9a41d83669020319a80574b804a5f95cbd7e"
        case .jungle3:
            return "2a02a0053e5a8cf73a56ba0fda11e4d92e0238a4a2aa74fccf46d5a910746840"
        case .jungle4:
            return "73e4385a2708e6d7048834fbc1079f2fabb17b3c125b146af438971e90716c4d"
        case .proton:
            return "384da888112027f0321850a169f737c33e53b388aad48b5adace4bab97f437e0"
        case .telos:
            return "4667b205c6838ef70ff7988f6e8257e8be0e1284a2f59699054a018f743b1d11"
        case .telosTestnet:
            return "1eaa0824707c8c16bd25145493bf062aecddfeb56c736f6ba6397f3195f33c9f"
        case .wax:
            return "1064487b3cd1a897ce03ae5b6a865651747e2e152090f99c1d19d44e01aea5a4"
        case .waxTestnet:
            return "f16b1833c747c43682f4386fca9cbb327929334a762755ebec17f6f23c9b8a12"
        case .libre:
            return "38b1d7815474d0c60683ecbea321d723e83f5da6ae5f1c1f9fecc69d9ba96465"
        case .libreTestnet:
            return "b64646740308df2ee06c6b72f34c0f7fa066d940e831f752db2006fcc2b78dee"
        case .ux:
            return "8fc6dce7942189f842170de953932b1f66693ad3788f766e777b6f9d22335c02"
        }
    }

    var nodeUrl: URL {
        switch self {
        case .eos:
            return URL(string: "https://eos.greymass.com")!
        case .fio:
            return URL(string: "https://fio.greymass.com")!
        case .fioTestnet:
            return URL(string: "https://fiotestnet.greymass.com")!
        case .jungle3:
            return URL(string: "https://jungle3.greymass.com")!
        case .jungle4:
            return URL(string: "https://jungle4.greymass.com")!
        case .proton:
            return URL(string: "https://proton.greymass.com")!
        case .telos:
            return URL(string: "https://telos.greymass.com")!
        case .telosTestnet:
            return URL(string: "https://telostestnet.greymass.com")!
        case .wax:
            return URL(string: "https://wax.greymass.com")!
        case .waxTestnet:
            return URL(string: "https://waxtestnet.greymass.com")!
        case .libre:
            return URL(string: "https://libre.greymass.com/")!
        case .libreTestnet:
            return URL(string: "https://libretestnet.greymass.com/")!
        case .ux:
            return URL(string: "https://api.uxnetwork.io")!
        }
    }

    var chainLookupSupport: Bool {
        !(self == .fio || self == .fioTestnet)
    }

    static let defaultNetwork = Network.eos
    static let mainNetworks: [Self] = [
        .eos,
        .fio,
        .telos,
        .wax,
        .proton,
        .libre,
        .ux,
    ]
    static let testNetworks: [Self] = [
        .fioTestnet,
        .jungle3,
        .jungle4,
        .telosTestnet,
        .waxTestnet,
        .libreTestnet
    ]
    static let allNetworks: [Self] = Self.mainNetworks + Self.testNetworks
}
