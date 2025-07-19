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
        let client = Client(clientID: "abc", name: "Alice")
        try clients.set(client)
        let loaded = clients.get("abc")
        XCTAssertEqual(loaded?.name, "Alice")
    }

    func testOverwriteClient() throws {
        try clients.set(Client(clientID: "1", name: "Alice"))
        try clients.set(Client(clientID: "1", name: "Bob"))
        XCTAssertEqual(clients.get("1")?.name, "Bob")
    }
}
