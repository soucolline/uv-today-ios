// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let tca: Target.Dependency = .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
let tcaCoreLocation: Target.Dependency = .product(name: "ComposableCoreLocation", package: "composable-core-location")

let package = Package(
    name: "uv-today-ios",
    platforms: [.iOS(.v15)],
    products: [
      .library(name: "AppFeature", targets: ["AppFeature"]),
      .library(name: "LocationManager", targets: ["LocationManager"]),
      .library(name: "Models", targets: ["Models"]),
      .library(name: "UVClient", targets: ["UVClient"])
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "0.51.0"),
      .package(url: "https://github.com/pointfreeco/composable-core-location", exact: "0.2.0"),
    ],
    targets: [
      .target(
        name: "AppFeature",
        dependencies: [
          "LocationManager",
          "Models",
          "UVClient",
          tca,
          tcaCoreLocation
        ]
      ),
      .target(
        name: "LocationManager",
        dependencies: [
          tcaCoreLocation
        ]
      ),
      .target(name: "Models"),
      .target(
        name: "UVClient",
        dependencies: [
          "Models",
          tca
        ]
      ),
      .testTarget(
        name: "AppFeatureTests",
        dependencies: [
          "AppFeature",
          "Models",
          "UVClient",
          tca
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
