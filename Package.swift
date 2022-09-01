// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "uv-today-ios",
    platforms: [.iOS(.v15)],
    products: [
      .library(name: "Models", targets: ["Models"])
    ],
    dependencies: [
    ],
    targets: [
      .target(name: "Models")
    ]
)
