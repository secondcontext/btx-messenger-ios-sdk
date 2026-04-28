// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "BTXCustomerMessengerKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "BTXCustomerMessengerKit",
            targets: ["BTXCustomerMessengerKit"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "BTXCustomerMessengerKit",
            url: "https://github.com/secondcontext/btx-messenger-ios-sdk/releases/download/0.1.0/BTXCustomerMessengerKit-0.1.0.xcframework.zip",
            checksum: "878667c6b8ae06eca50959e82c11af269e58efb506d84eef2b2e7aa2aa9c457c"
        ),
    ]
)
