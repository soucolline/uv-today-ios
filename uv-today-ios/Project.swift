import ProjectDescription

let project = Project(
    name: "uv-today-ios",
    targets: [
        .target(
            name: "uv-today-ios",
            destinations: .iOS,
            product: .app,
            bundleId: "com.zlatan.swiftUV",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .file(path: "Info.plist"),
            sources: ["uv-today-ios/Sources/**"],
            resources: ["uv-today-ios/Resources/**"],
            dependencies: [
              .target(name: "AppFeature"),
              .target(name: "UVClient"),
              .target(name: "LocationManager"),
              .external(name: "FirebaseCrashlytics")
            ]
        ),
        .target(
            name: "uv-today-iosTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.zlatan.swiftUV-iosTests",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .default,
            sources: ["uv-today-ios/Tests/**"],
            resources: [],
            dependencies: [.target(name: "uv-today-ios")]
        ),
        .target(
            name: "Models",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zlatan.swiftUV.Models",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(with: [:]),
            sources: ["Models/Sources/**"],
            resources: [],
            dependencies: []
        ),
        .target(
            name: "UVClient",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zlatan.swiftUV.UVClient",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(with: [:]),
            sources: ["UVClient/Sources/**"],
            resources: [],
            dependencies: [
              .external(name: "Dependencies"),
              .target(name: "Models")
            ]
        ),
        .target(
            name: "LocationManager",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zlatan.swiftUV.LocationManager",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(with: [:]),
            sources: ["LocationManager/Sources/**"],
            resources: [],
            dependencies: [
              .external(name: "Dependencies"),
            ]
        ),
        .target(
            name: "AppFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zlatan.swiftUV.AppFeature",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(with: [:]),
            sources: ["AppFeature/Sources/**"],
            resources: [],
            dependencies: [
              .target(name: "LocationManager"),
              .target(name: "Models"),
              .target(name: "UVClient"),
              .external(name: "Perception"),
              .external(name: "Dependencies"),
            ]
        ),
    ]
)
