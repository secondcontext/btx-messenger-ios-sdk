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
            url: "https://github.com/secondcontext/btx-ios-sdk/releases/download/0.2.1/BTXClientKit.xcframework.zip",
            checksum: "ac2c1daf35a66f91fdf42fd95fda08d6a80fbd67a324ffcf749f70918a5814e8"
        ),
    ]
)
