import Foundation
import NDJSONStore

public struct Client: NDJSONIdentifiable, Codable, Equatable {
    public let clientId: String
    public let clientSecret: String
    public let redirectUris: [String]
    public let scopes: [String]


    public var ndjsonKey: String {
        clientId
    }

    public init(
        clientId: String,
        clientSecret: String,
        redirectUris: [String],
        scopes: [String]
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.redirectUris = redirectUris
        self.scopes = scopes
    }
}
