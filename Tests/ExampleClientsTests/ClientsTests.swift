import XCTest
@testable import NDJSONStore

final class ClientsTests: XCTestCase {
    var tempFileURL: URL!
    var clients: Clients!

    override func setUp() {
        super.setUp()
        tempFileURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent("clients_test.ndjson")
        try? FileManager.default.removeItem(at: tempFileURL)
        clients = try! Clients(fileURL: tempFileURL)
    }

    override func tearDown() {
       // try? FileManager.default.removeItem(at: tempFileURL)
        clients = nil
        super.tearDown()
    }

    func testSetAndGetClient() throws {
        let client = Client(clientID: "client-1", clientSecret: "client-secret-1", redirectURIs: ["http://example.com"], scopes: ["read", "write"])
        try clients.set(client)
        let loaded = clients.get("client-1")
        XCTAssertEqual(loaded?.clientSecret, "client-secret-1")
        XCTAssertEqual(loaded?.redirectURIs, ["http://example.com"])
        XCTAssertEqual(loaded?.scopes, ["read", "write"])
    }

    // func testOverwriteClient() throws {
    //     try clients.set(Client(clientID: "1", name: "Alice"))
    //     try clients.set(Client(clientID: "1", name: "Bob"))
    //     XCTAssertEqual(clients.get("1")?.name, "Bob")
    // }
}
