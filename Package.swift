// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MetalViewUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v10_15),
        .tvOS(.v17),
    ],
    products: [
        .library(
            name: "MetalViewUI",
            targets: ["MetalViewUI"]
        ),
    ],
    targets: [
        .target(
            name: "MetalViewUI",
            dependencies: []
        ),
    ],
    swiftLanguageVersions: [.v5]
)
