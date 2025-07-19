import Foundation
import NDJSONStore

public struct Client: NDJSONIdentifiable, Codable, Equatable {
    public let clientID: String
    public let clientSecret: String
    public let redirectURIs: [String]
    public let scopes: [String]

    // NOTE: CodingKeys works in conjunction with the Clients.swift
    // class which needs to call the NDJSONStore constructor setting
    // useDefaultDecodingStrategy to false, otherwise the decoder
    // will FAIL and not throw an error. It cannot deal with decoding
    // strategies specified both as Coding keys in a Codable object
    // and as a strategy in the decoder.
    enum CodingKeys: String, CodingKey {
        case clientID = "client_id"
        case clientSecret = "client_secret"
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
