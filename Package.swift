// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "uv-today-ios",
    platforms: [.iOS(.v15)],
    products: [
      .library(name: "Models", targets: ["Models"]),
      .library(name: "UVClient", targets: ["UVClient"])
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.39.1")
    ],
    targets: [
      .target(name: "Models"),
      .target(
        name: "UVClient",
        dependencies: [
          "Models",
          .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]
      )
    ]
)
