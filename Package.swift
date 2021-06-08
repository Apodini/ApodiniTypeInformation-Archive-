// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let enumSupport = true
let runtime: Package.Dependency = enumSupport
    ? .package(url: "https://github.com/PSchmiedmayer/Runtime.git", .revision("b810847a466ecd1cf65e7f39e6e715734fdc672c"))
    : .package(url: "https://github.com/wickwirew/Runtime.git", from: "2.2.2")

let package = Package(
    name: "ApodiniTypeInformation",
    platforms: [
        .macOS(.v10_15), .iOS(.v14)
    ],
    products: [
        .library(name: "ApodiniTypeInformation", targets: ["ApodiniTypeInformation"])
    ],
    dependencies: [runtime],
    targets: [
        .target(
            name: "ApodiniTypeInformation",
            dependencies: [
                .product(name: "Runtime", package: "Runtime")
            ]
        ),
        .testTarget(
            name: "ApodiniTypeInformationTests",
            dependencies: ["ApodiniTypeInformation"])
    ]
)
