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
            url: "https://github.com/secondcontext/btx-ios-sdk/releases/download/0.2.9/BTXClientKit.xcframework.zip",
            checksum: "0b80316695a1c62456e0ccdd6885019b2cfc52be8d5390bcf2107a2ba3550221"
        ),
    ]
)
