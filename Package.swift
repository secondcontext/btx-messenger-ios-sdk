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
            url: "https://github.com/secondcontext/btx-ios-sdk/releases/download/0.2.2/BTXClientKit.xcframework.zip",
            checksum: "a510691c99b87a8a60570ea52d3f2027e5f5b34047456b397fb6b3c375cfd0fc"
        ),
    ]
)
