// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "RewireCoreData",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "RewireCoreData",
            targets: ["RewireCoreData"]),
    ],
    dependencies: [
        // No external dependencies
    ],
    targets: [
        .target(
            name: "RewireCoreData",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "RewireCoreDataTests",
            dependencies: ["RewireCoreData"],
            path: "Tests"),
    ]
) 