// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let IS_APPLE: SwiftSetting = .define("IS_APPLE", .when(platforms: [.macOS, .iOS]))

let package = Package(
    name: "swift-essentials-nfc",
    platforms: [
        .macOS("13.3"),
        .iOS("16.4"),
    ],
    products: [
        .library(name: "EssentialsNFC", targets: ["EssentialsNFC"]),
        .library(name: "NDEF", targets: ["NDEF"]),
        .library(name: "TLV", targets: ["TLV"]),
        .library(name: "ISO7816", targets: ["ISO7816"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/apple/swift-log",
            .upToNextMajor(from: "1.6.1")
        ),
        .package(
            url: "https://github.com/lumoscompany/swift-essentials",
            .upToNextMajor(from: "0.0.10")
        ),
    ],
    targets: [
        .target(
            name: "EssentialsNFC",
            dependencies: [
                "TLV",
                "NDEF",
                "ISO7816",
            ],
            path: "Sources/EssentialsNFC",
            swiftSettings: [IS_APPLE]
        ),
        .target(
            name: "TLV",
            dependencies: [
                .product(name: "Essentials", package: "swift-essentials"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/TLV",
            swiftSettings: [IS_APPLE]
        ),
        .target(
            name: "NDEF",
            dependencies: [
                .product(name: "Essentials", package: "swift-essentials"),
                .product(name: "Logging", package: "swift-log"),
            ],
            path: "Sources/NDEF",
            swiftSettings: [IS_APPLE]
        ),
        .target(
            name: "ISO7816",
            dependencies: [
                .product(name: "Essentials", package: "swift-essentials"),
            ],
            path: "Sources/ISO7816",
            swiftSettings: [IS_APPLE]
        ),
        .testTarget(
            name: "TLVTests",
            dependencies: ["TLV"],
            path: "Tests/TLVTests"
        ),
        .testTarget(
            name: "NDEFTests",
            dependencies: [
                "NDEF",
                "TLV",
                .product(name: "Essentials", package: "swift-essentials"),
            ],
            path: "Tests/NDEFTests"
        ),
    ]
)
