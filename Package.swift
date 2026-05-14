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
            url: "https://github.com/secondcontext/btx-ios-sdk/releases/download/0.2.4/BTXClientKit.xcframework.zip",
            checksum: "af0231260feccdea827783794b30c42c281f7f3c711714f64e619d6da71152c3"
        ),
    ]
)
