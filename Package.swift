// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "NDJSONStore",
    platforms: [.macOS(.v12)],
    products: [
        .library(name: "NDJSONStore", targets: ["NDJSONStore"])
    ],
    targets: [
        .target(
            name: "NDJSONStore",
            path: "Sources/NDJSONStore"
        ),
        .testTarget(
            name: "NDJSONStoreTests",
            dependencies: ["NDJSONStore"],
            path: "Tests/NDJSONStoreTests"
        ),
        .testTarget(
            name: "ExampleClientsTests",
            dependencies: ["NDJSONStore"],
            path: "Tests/ExampleClientsTests"
        ),
        // .testTarget(
        //     name: "ExamplesTokensTests",
        //     dependencies: ["NDJSONStore"],
        //     path: "Tests/ExamplesTokensTests"
        // )
    ]
)
