// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "BTXClientKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "BTXClientKit",
            targets: ["BTXClientKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "BTXClientKit",
            url: "https://github.com/secondcontext/btx-ios-sdk/releases/download/0.2.3/BTXClientKit.xcframework.zip",
            checksum: "b061affed2c0d273be4ecf5894880ac3dc2708fe25a7e07b19c08f6601f7fb08"
        ),
    ]
)
