// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "AppleMusicClient",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "AppleMusicClient",
            targets: ["AppleMusicClient"]),
    ],
    dependencies: [
        .package(path: "../MoodCore")
    ],
    targets: [
        .target(
            name: "AppleMusicClient",
            dependencies: ["MoodCore"]),
        .testTarget(
            name: "AppleMusicClientTests",
            dependencies: ["AppleMusicClient"]),
    ]
)