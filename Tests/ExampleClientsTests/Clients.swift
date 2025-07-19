import Foundation
import NDJSONStore

public class Clients {
    private let store: NDJSONStore<String, Client>

    public init(fileURL: URL) throws {
        self.store = NDJSONStore<String, Client>(
            fileURL: fileURL,
            keyExtractor: { $0.clientId }
        )
    }

    public func get(_ id: String) -> Client? {
        return store.get(id)
    }

    public func set(_ client: Client) throws {
        store.set(client)
    }
    public func flush() throws {
        try? store.flush()
    }

    public func close() {
        try? store.close()
    }
}
