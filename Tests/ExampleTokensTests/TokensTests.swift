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
        print("tempFileURL: \(tempFileURL.absoluteString)")
    }

    override func tearDownWithError() throws {
        // Clean up temp file after test
        // try? FileManager.default.removeItem(at: tempFileURL)
    }

    func testSetGetTokens() throws {
        let tokens = try Tokens(fileURL: tempFileURL)

        let accessToken = AccessToken(accessToken: "access123", clientID: "client123", scope: ["read", "write"], issuedAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970))), expiresAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970) + 3600)))
        let refreshToken = RefreshToken(refreshToken: "refreshABC", clientID: "client123", scope: ["read", "write"], issuedAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970))))

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
            tokens.set(.access(AccessToken(accessToken: "token1", clientID: "client1", scope: ["read", "write"], issuedAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970))), expiresAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970) + 10)))))
            tokens.set(.refresh(RefreshToken(refreshToken: "token2", clientID: "client1", scope: ["read", "write"], issuedAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970))))))
            tokens.close()
        }

        // Re-open store, verify tokens are loaded from file
        do {
            let tokens = try Tokens(fileURL: tempFileURL)

            XCTAssertNotNil(tokens.get("token1"))
            XCTAssertNotNil(tokens.get("token2"))
        }
    }

    func testWritePerformance_precise() throws {
        let totalTokens = 100_000
        let tokens = try Tokens(fileURL: tempFileURL)

        // Prepare data ahead of time (outside timing block)
        var sampleTokens: [Token] = []
        for i in 1...totalTokens {
            if i % 2 == 0 {
                // Even numbers are access tokens
                let accessToken = AccessToken(
                    accessToken: "access_token_\(i)",
                    clientID: "client1",
                    scope: ["read", "write"],
                    issuedAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970))),
                    expiresAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970) + 3600))
                )
                sampleTokens.append(.access(accessToken))
            } else {
                // Odd numbers are refresh tokens
                let refreshToken = RefreshToken(
                    refreshToken: "refresh_token_\(i)",
                    clientID: "client1",
                    scope: ["read", "write"],
                    issuedAt: Date(timeIntervalSince1970: TimeInterval(Int(Date().timeIntervalSince1970) + i))
                )
                sampleTokens.append(.refresh(refreshToken))
            }
        }

        // Measure only the write and flush
        let start = DispatchTime.now()
        for token in sampleTokens {
            tokens.set(token)
        }
        tokens.close()
        let end = DispatchTime.now()

        let elapsed = Double(end.uptimeNanoseconds - start.uptimeNanoseconds)
        let nsPerOp = elapsed / Double(totalTokens)
        let opsPerSec = 1_000_000_000 / nsPerOp

        print("Token Write throughput:")
        print("  Total tokens: \(totalTokens)")
        print("  Access tokens: \(totalTokens / 2)")
        print("  Refresh tokens: \(totalTokens / 2)")
        print("  Time elapsed: \(elapsed / 1_000_000) ms")
        print("  ns/op: \(Int(nsPerOp))")
        print("  ops/sec: \(Int(opsPerSec))")
    }
}
