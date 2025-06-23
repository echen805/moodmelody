// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MoodCore",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "MoodCore",
            targets: ["MoodCore"]),
    ],
    targets: [
        .target(
            name: "MoodCore",
            dependencies: []),
        .testTarget(
            name: "MoodCoreTests",
            dependencies: ["MoodCore"]),
    ]
)