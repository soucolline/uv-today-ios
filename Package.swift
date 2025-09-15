// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let dependencies: Target.Dependency = .product(name: "Dependencies", package: "swift-dependencies")

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
      .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.9.2")
    ],
    targets: [
      .target(
        name: "AppFeature",
        dependencies: [
          "LocationManager",
          "Models",
          "UVClient",
          dependencies
        ],
        swiftSettings: [
          .defaultIsolation(MainActor.self)
        ]
      ),
      .target(
        name: "LocationManager",
        dependencies: [
          dependencies
        ],
        swiftSettings: [
          .defaultIsolation(MainActor.self)
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
