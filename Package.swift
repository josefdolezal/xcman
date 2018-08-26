// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcman",
    products: [
        .executable(name: "xcman", targets: ["xcman"]),
        .library(name: "XCManLib", targets: ["XCManLib"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "xcman",
            dependencies: ["XCManLib"]),
        .target(
            name: "XCManLib",
            dependencies: [])
    ]
)
