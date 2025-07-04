// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GlucoseTracker",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GlucoseTracker",
            targets: ["GlucoseTracker"]),
    ],
    dependencies: [
        // Add dependencies if needed for future enhancements
        // .package(url: "https://github.com/realm/realm-swift.git", from: "10.44.0"),
        // .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.0"),
    ],
    targets: [
        .target(
            name: "GlucoseTracker",
            dependencies: []),
        .testTarget(
            name: "GlucoseTrackerTests",
            dependencies: ["GlucoseTracker"]),
    ]
)