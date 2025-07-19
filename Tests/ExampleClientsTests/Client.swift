import Foundation
import NDJSONStore

public struct Client: NDJSONIdentifiable, Codable, Equatable {
    public let clientID: String
    public let clientSecret: String
    public let redirectURIs: [String]
    public let scopes: [String]

    enum CodingKeys: String, CodingKey {
        case clientID
        case clientSecret
        case redirectURIs = "redirect_uris"
        case scopes
    }
    
    public var ndjsonKey: String {
        clientID
    }

    public init(
        clientID: String,
        clientSecret: String,
        redirectURIs: [String],
        scopes: [String]
    ) {
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.redirectURIs = redirectURIs
        self.scopes = scopes
    }
}
