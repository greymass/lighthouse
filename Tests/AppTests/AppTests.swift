@testable import App
import XCTVapor

final class AppTests: XCTestCase {
    func testLookup() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        try configure(app)

        try app.test(.GET, "lookup/badkey") { res in
            XCTAssertEqual(res.status, .badRequest)
        }

        try app.test(.GET, "lookup/EOS6RWZ1CmDL4B6LdixuertnzxcRuUDac3NQspJEvMnebGcUwhvfX?includeTestnets") { res in
            XCTAssertEqual(res.status, .ok)
            let accounts = try res.content.decode([AccountLookup.NetworkAccounts].self)
            XCTAssert(!accounts.isEmpty)
        }
    }
}
