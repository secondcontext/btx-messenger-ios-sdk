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
            url: "https://github.com/secondcontext/btx-ios-sdk/releases/download/0.3.2/BTXClientKit.xcframework.zip",
            checksum: "1ebed082f5110d5746a368b167856ea2f07ecf0a71bf2a14d62e611ac6c09511"
        ),
    ]
)
