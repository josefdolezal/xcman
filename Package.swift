// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xcman",
    products: [
        .executable(name: "xcman", targets: ["xcman"]),
        .library(name: "XCManLib", targets: ["XCManLib"])
    ],
    dependencies: [
        .package(url: "https://github.com/kylef/Commander.git", from: "0.8.0")
    ],
    targets: [
        .target(
            name: "xcman",
            dependencies: ["XCManLib", "Commander"]),
        .target(
            name: "XCManLib",
            dependencies: [])
    ]
)
