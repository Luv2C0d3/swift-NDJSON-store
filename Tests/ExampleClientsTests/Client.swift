import Foundation
import NDJSONStore

public struct Client: NDJSONIdentifiable, Codable, Equatable {
    public let clientID: String
    public let name: String

    // Required by NDJSONIdentifiable
    public var ndjsonKey: String {
        clientID
    }

    public init(clientID: String, name: String) {
        self.clientID = clientID
        self.name = name
    }
}
