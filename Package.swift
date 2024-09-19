// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let perception: Target.Dependency = .product(name: "Perception", package: "swift-perception")
let dependencies: Target.Dependency = .product(name: "Dependencies", package: "swift-dependencies")

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
      .package(url: "https://github.com/pointfreeco/swift-perception", exact: "1.3.5"),
      .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.4.0")
    ],
    targets: [
      .target(
        name: "AppFeature",
        dependencies: [
          "LocationManager",
          "Models",
          "UVClient",
          perception,
          dependencies
        ]
      ),
      .target(
        name: "LocationManager",
        dependencies: [
          dependencies
        ]
      ),
      .target(name: "Models"),
      .target(
        name: "UVClient",
        dependencies: [
          "Models",
          dependencies
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
