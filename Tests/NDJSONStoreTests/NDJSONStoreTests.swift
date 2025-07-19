import XCTest
@testable import NDJSONStore

final class NDJSONStoreTests: XCTestCase {
    struct Client: Codable, NDJSONIdentifiable {
        let client_id: String
        var ndjsonKey: String { client_id }
    }

    func testWriteAndRead() throws {
        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("test.ndjson")
        let store = NDJSONStore<String, Client>(fileURL: tmpURL) { $0.client_id }

        let c1 = Client(client_id: "abc123")
        store.set(c1)

        let c2 = store.get("abc123")
        XCTAssertEqual(c1.client_id, c2?.client_id)

        store.close()
    }
}

