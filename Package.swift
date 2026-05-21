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
            url: "https://github.com/secondcontext/btx-ios-sdk/releases/download/0.2.6/BTXClientKit.xcframework.zip",
            checksum: "df161c70741aa315ece73c9bfe6f445b105e0891bf64886c5b7bcb66c3b96493"
        ),
    ]
)
