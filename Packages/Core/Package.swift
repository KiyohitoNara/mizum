// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [
        .iOS(.v26)
    ],
    products: [
        .library(name: "Core", targets: ["Core"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "Core",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms")
            ]),
        .testTarget(name: "CoreTests", dependencies: ["Core"])
    ]
)
