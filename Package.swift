// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NDJSONStore",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "NDJSONStore",
            targets: ["NDJSONStore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NDJSONStore",
            dependencies: []
        ),
        .testTarget(
            name: "NDJSONStoreTests",
            dependencies: ["NDJSONStore"]
        ),
    ]
)
