// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Shazam",
    platforms: [.iOS(.v9)],
    products: [
        .library(
            name: "Shazam",
            targets: ["Shazam"]),
    ],
    targets: [
        .target(
            name: "Shazam",
            dependencies: []),
    ]
)
