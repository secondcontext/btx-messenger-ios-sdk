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
            url: "https://github.com/secondcontext/btx-messenger-ios-sdk/releases/download/0.2.0/BTXClientKit.xcframework.zip",
            checksum: "854d5e9e18d34fb4e07049e8acb51d5e54214f35726a9cec0e9c1943b1195935"
        ),
    ]
)
