// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Amigos Chat Package",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "AmigosChat",
            targets: ["Amigos Chat Package"])
    ],
    dependencies: [
        .package(url: "https://github.com/GetStream/stream-chat-swift", exact: "4.81.0"),
        .package(url: "https://github.com/GetStream/stream-chat-swiftui", exact: "4.81.0"),
        .package(url: "https://github.com/SDWebImage/SDWebImageSwiftUI", exact: "3.1.3"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.58.2")
    ],
    targets: [
        .target(
            name: "Amigos Chat Package",
            dependencies: [
                .product(name: "StreamChat", package: "stream-chat-swift"),
                .product(name: "StreamChatSwiftUI", package: "stream-chat-swiftui"),
                .product(name: "SDWebImageSwiftUI", package: "SDWebImageSwiftUI"),
            ],
            resources: [
                .process("Resources")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        ),
        .testTarget(
            name: "AmigosChatUnitTests",
            dependencies: ["Amigos Chat Package"],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")]
        )
    ]
)
