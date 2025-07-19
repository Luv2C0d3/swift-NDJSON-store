import Foundation
import NDJSONStore

public struct Client: NDJSONIdentifiable, Codable, Equatable {
    public let clientId: String
    public let clientSecret: String
    public let redirectUris: [String]
    public let scopes: [String]

    // TODO understand what is it with CodingKeys and how it would
    // work. CodingKeys would allow me to call ClientId clientID
    // and  redirectUris redirectURIs. BUT, I need to understand
    // how the CodingKeys work with the NDJSONStore and thus the
    // NDJSONDecoder.

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
