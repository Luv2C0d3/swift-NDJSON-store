import XCTest
@testable import NDJSONStore
import Foundation

final class TokensTests: XCTestCase {
    var tempFileURL: URL!

    override func setUpWithError() throws {
        // Create a temp file URL for testing
        let tempDir = URL(fileURLWithPath: NSTemporaryDirectory())
        tempFileURL = tempDir.appendingPathComponent("tokens_test.ndjson")
        // Remove if exists
        try? FileManager.default.removeItem(at: tempFileURL)
    }

    override func tearDownWithError() throws {
        // Clean up temp file after test
        // try? FileManager.default.removeItem(at: tempFileURL)
    }

    func testSetGetTokens() throws {
        let tokens = try Tokens(fileURL: tempFileURL)

        let accessToken = AccessToken(accessToken: "access123", expiresIn: 3600)
        let refreshToken = RefreshToken(refreshToken: "refreshABC", issuedAt: Date(timeIntervalSince1970: 1_600_000_000))

        // Store tokens
        tokens.set(.access(accessToken))
        tokens.set(.refresh(refreshToken))

        // Retrieve tokens by key
        let fetchedAccess = tokens.get("access123")
        let fetchedRefresh = tokens.get("refreshABC")

        // Verify retrieval matches inserted tokens
        switch fetchedAccess {
        case .access(let at)?:
            XCTAssertEqual(at, accessToken)
        default:
            XCTFail("Expected AccessToken")
        }

        switch fetchedRefresh {
        case .refresh(let rt)?:
            XCTAssertEqual(rt, refreshToken)
        default:
            XCTFail("Expected RefreshToken")
        }
    }

    func testPersistenceAcrossInstances() throws {
        // Create tokens and store them
        do {
            let tokens = try Tokens(fileURL: tempFileURL)
            tokens.set(.access(AccessToken(accessToken: "token1", expiresIn: 10)))
            tokens.set(.refresh(RefreshToken(refreshToken: "token2", issuedAt: Date())))
            tokens.close()
        }

        // Re-open store, verify tokens are loaded from file
        do {
            let tokens = try Tokens(fileURL: tempFileURL)

            XCTAssertNotNil(tokens.get("token1"))
            XCTAssertNotNil(tokens.get("token2"))
        }
    }
}
