// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PhotoManager115",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "PhotoManager115",
            targets: ["PhotoManager115"]
        ),
    ],
    dependencies: [
        // Add dependencies here if needed for WebDAV, networking, etc.
    ],
    targets: [
        .target(
            name: "PhotoManager115",
            dependencies: [],
            path: "Sources",
            linkerSettings: [
                .linkedFramework("Foundation", .when(platforms: [.iOS, .macOS])),
            ]
        ),
        .testTarget(
            name: "PhotoManager115Tests",
            dependencies: ["PhotoManager115"],
            path: "Tests"
        ),
    ]
)
