import Foundation
import NDJSONStore // your module where NDJSONStore is defined

// MARK: - Token Types

public struct AccessToken: Codable, NDJSONIdentifiable, Equatable {
    public let accessToken: String
    public let clientID: String
    public let scope: [String]
    public let issuedAt: Date
    public let expiresAt: Date

    public var ndjsonKey: String { accessToken }

    public init(accessToken: String, clientID: String, scope: [String], issuedAt: Date, expiresAt: Date) {
        self.accessToken = accessToken
        self.clientID = clientID
        self.scope = scope
        self.issuedAt = issuedAt
        self.expiresAt = expiresAt
    }
}

public struct RefreshToken: Codable, NDJSONIdentifiable, Equatable {
    public let refreshToken: String
    public let clientID: String
    public let scope: [String]
    public let issuedAt: Date

    public var ndjsonKey: String { refreshToken }

    public init(refreshToken: String, clientID: String, scope: [String], issuedAt: Date) {
        self.refreshToken = refreshToken
        self.clientID = clientID
        self.scope = scope
        self.issuedAt = issuedAt
    }
}

// MARK: - Polymorphic Token enum

public enum Token: Codable, NDJSONIdentifiable, Equatable {
    case access(AccessToken)
    case refresh(RefreshToken)

    // Provide the protocol property by forwarding to wrapped value
    public var ndjsonKey: String {
        switch self {
        case .access(let accessToken):
            return accessToken.ndjsonKey
        case .refresh(let refreshToken):
            return refreshToken.ndjsonKey
        }
    }

    // Implement Codable conformance by forwarding
    public init(from decoder: Decoder) throws {
        // Try decoding AccessToken first
        if let accessToken = try? AccessToken(from: decoder) {
            self = .access(accessToken)
            return
        }
        // Otherwise, try decoding RefreshToken
        let refreshToken = try RefreshToken(from: decoder)
        self = .refresh(refreshToken)
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .access(let accessToken):
            try accessToken.encode(to: encoder)
        case .refresh(let refreshToken):
            try refreshToken.encode(to: encoder)
        }
    }
}

// MARK: - Tokens Store (Facade)

public class Tokens {
    private let store: NDJSONStore<String, Token>

    public init(fileURL: URL) throws {
        // Key extractor uses Token's ndjsonKey
        self.store = NDJSONStore<String, Token>(
            fileURL: fileURL,
            keyExtractor: { $0.ndjsonKey }
        )
    }

    public func get(_ key: String) -> Token? {
        store.get(key)
    }

    public func set(_ token: Token) {
        store.set(token)
    }

    public func close() {
        try? store.close()
    }
}
