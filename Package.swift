// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "uv-today-ios",
    platforms: [.iOS(.v15)],
    products: [
      .library(name: "AppFeature", targets: ["AppFeature"]),
      .library(name: "Models", targets: ["Models"]),
      .library(name: "UVClient", targets: ["UVClient"])
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.42.0"),
      .package(url: "https://github.com/pointfreeco/composable-core-location", exact: "0.2.0"),
    ],
    targets: [
      .target(
        name: "AppFeature",
        dependencies: [
          "Models",
          "UVClient",
          .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
          .product(name: "ComposableCoreLocation", package: "composable-core-location")
        ]
      ),
      .target(name: "Models"),
      .target(
        name: "UVClient",
        dependencies: [
          "Models",
          .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]
      ),
      .testTarget(
        name: "AppFeatureTests",
        dependencies: [
          "AppFeature",
          "Models",
          "UVClient",
          .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
        ]
      ),
      .testTarget(
        name: "ModelsTests",
        dependencies: [
          "Models"
        ]
      )
    ]
)
