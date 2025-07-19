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
        let client = Client(
            clientId: "client-1", clientSecret: "client-secret-1",
            redirectUris: ["http://example.com"], scopes: ["read", "write"])
        try clients.set(client)
        let loaded = clients.get("client-1")
        XCTAssertEqual(loaded?.clientSecret, "client-secret-1")
        XCTAssertEqual(loaded?.redirectUris, ["http://example.com"])
        XCTAssertEqual(loaded?.scopes, ["read", "write"])
    }

    // func testOverwriteClient() throws {
    //     try clients.set(Client(clientID: "1", name: "Alice"))
    //     try clients.set(Client(clientID: "1", name: "Bob"))
    //     XCTAssertEqual(clients.get("1")?.name, "Bob")
    // }
    func testWriteAndReadMultipleClients() throws {
        // Write 10 clients to the first store
        for i in 1...10 {
            let client = Client(
                clientId: "client-\(i)",
                clientSecret: "client-secret-\(i)",
                redirectUris: ["http://example.com"],
                scopes: ["read", "write"]
            )
            try clients.set(client)
        }
        try clients.flush()
        // try clients.close()
        // Read from a new store backed by the same file
        let clients2 = try! Clients(fileURL: tempFileURL)

        // Compare each client
        for i in 1...10 {
            let key = "client-\(i)"
            let c1 = clients.get(key)
            let c2 = clients2.get(key)
            XCTAssertEqual(c1, c2, "Mismatch on client with id \(key)")
        }
    }

}
