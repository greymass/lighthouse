import Vapor

func routes(_ app: Application) throws {
    app.get { _ in
        "💡🏠"
    }

    let accountLookup = AccountLookup()
    app.get("lookup", ":key", use: accountLookup.lookup)
}
