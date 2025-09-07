// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "safari tabs layout",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "safari tabs layout",
            targets: ["safari tabs layout"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "safari tabs layout"),
        .testTarget(
            name: "safari tabs layoutTests",
            dependencies: ["safari tabs layout"]
        ),
    ]
)
