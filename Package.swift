// swift-tools-version: 6.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let dependencies: Target.Dependency = .product(name: "Dependencies", package: "swift-dependencies")
let composableArchitecture: Target.Dependency = .product(
  name: "ComposableArchitecture",
  package: "swift-composable-architecture"
)

let package = Package(
    name: "uv-today-ios",
    platforms: [.iOS(.v18)],
    products: [
      .library(name: "AppFeature", targets: ["AppFeature"]),
      .library(name: "LocationManager", targets: ["LocationManager"]),
      .library(name: "Models", targets: ["Models"]),
      .library(name: "UVClient", targets: ["UVClient"])
    ],
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-composable-architecture", exact: "1.26.2"),
      .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.17.2")
    ],
    targets: [
      .target(
        name: "AppFeature",
        dependencies: [
          "LocationManager",
          "Models",
          "UVClient",
          composableArchitecture
        ]
      ),
      .target(
        name: "LocationManager",
        dependencies: [
          "Models",
          dependencies
        ]
      ),
      .target(name: "Models"),
      .target(
        name: "UVClient",
        dependencies: [
          "Models",
          dependencies
        ],
        swiftSettings: [
          .defaultIsolation(MainActor.self)
        ]
      ),
      .testTarget(name: "AppFeatureTests", dependencies: ["AppFeature"]),
      .testTarget(
        name: "ModelsTests",
        dependencies: [
          "Models"
        ],
        swiftSettings: [
          .defaultIsolation(MainActor.self)
        ]
      )
    ]
)
