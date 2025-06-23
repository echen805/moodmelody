// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "UIComponents",
            targets: ["UIComponents"]),
    ],
    dependencies: [
        .package(path: "../MoodCore"),
        .package(path: "../AppleMusicClient")
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: ["MoodCore", "AppleMusicClient"]),
        .testTarget(
            name: "UIComponentsTests",
            dependencies: ["UIComponents"]),
    ]
)