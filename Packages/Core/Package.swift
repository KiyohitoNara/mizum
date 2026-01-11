// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(name: "Feature", targets: ["Feature"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "Feature",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ]),
        .testTarget(name: "FeatureTests", dependencies: ["Feature"])
    ]
)
