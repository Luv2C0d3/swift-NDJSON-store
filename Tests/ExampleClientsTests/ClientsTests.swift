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
            clientID: "client-1", clientSecret: "client-secret-1",
            redirectURIs: ["http://example.com"], scopes: ["read", "write"])
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
    func testWriteAndReadMultipleClients() throws {
        // Write 10 clients to the first store
        for i in 1...10 {
            let client = Client(
                clientID: "client-\(i)",
                clientSecret: "client-secret-\(i)",
                redirectURIs: ["http://example.com"],
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

    func testNDJSONStoreWritePerformance() throws {
        let totalClients = 10_000

        measure {

            // Write phase
            for i in 1...totalClients {
                let client = Client(
                    clientID: "client-\(i)",
                    clientSecret: "client-secret-\(i)",
                    redirectURIs: ["http://example.com"],
                    scopes: ["read", "write"]
                )
                try? clients.set(client)
            }
            try? clients.flush()
        }

        var clients2: Clients!
        // Read phase from a fresh store
        clients2 = try? Clients(fileURL: tempFileURL)

        // Final pass: correctness check
        for i in 1...totalClients {
            let key = "client-\(i)"
            let original = clients.get(key)
            let reloaded = clients2.get(key)
            XCTAssertEqual(original, reloaded, "Mismatch on client with id \(key)")
        }
    }

    func testNDJSONStoreReadPerformance() throws {
        let totalClients = 10_000

        // Write phase
        for i in 1...totalClients {
            let client = Client(
                clientID: "client-\(i)",
                clientSecret: "client-secret-\(i)",
                redirectURIs: ["http://example.com"],
                scopes: ["read", "write"]
            )
            try? clients.set(client)
        }
        try? clients.flush()

        var clients2: Clients!
        measure {
            // Read phase from a fresh store
            clients2 = try? Clients(fileURL: tempFileURL)
        }

        // Final pass: correctness check
        for i in 1...totalClients {
            let key = "client-\(i)"
            let original = clients.get(key)
            let reloaded = clients2.get(key)
            XCTAssertEqual(original, reloaded, "Mismatch on client with id \(key)")
        }
    }

    func testWritePerformance_precise() throws {
        let totalClients = 100_000

        // Prepare data ahead of time (outside timing block)
        var sampleClients: [Client] = []
        for i in 1...totalClients {
            let client = Client(
                clientID: "client-\(i)",
                clientSecret: "client-secret-\(i)",
                redirectURIs: ["http://example.com"],
                scopes: ["read", "write"]
            )
            sampleClients.append(client)
        }

        // Measure only the write and flush
        let start = DispatchTime.now()
        for client in sampleClients {
            try clients.set(client)
        }
        try clients.flush()
        let end = DispatchTime.now()

        let elapsed = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)
        let nsPerOp = elapsed / Double(totalClients)
        let opsPerSec = 1_000_000_000 / nsPerOp

        print("Write throughput:")
        print("  Total clients: \(totalClients)")
        print("  Time elapsed: \(elapsed / 1_000_000) ms")
        print("  ns/op: \(Int(nsPerOp))")
        print("  ops/sec: \(Int(opsPerSec))")
    }

}
