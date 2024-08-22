// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
      productTypes: [
          "Perception": .framework,
          "Dependencies": .framework,
          "IssueReporting": .framework,
          "XCTestDynamicOverlay": .framework
        ]
    )
#endif

let package = Package(
    name: "uv-today-ios",
    dependencies: [
      .package(url: "https://github.com/pointfreeco/swift-perception", exact: "1.1.5"),
      .package(url: "https://github.com/pointfreeco/swift-dependencies", exact: "1.2.2"),
      .package(url: "https://github.com/firebase/firebase-ios-sdk", exact: "10.24.0"),
    ]
)
