// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FluentContentMacro",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "FluentContentMacro",
            targets: ["FluentContentMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "600.0.0-latest"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", branch: "main"),
    ],
    targets: [
        .macro(
            name: "FluentContentMacros",
            dependencies: [
                "FluentContentMacroShared",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        // Library that exposes a macro as part of its API.
        .target(
            name: "FluentContentMacro",
            dependencies: [
                "FluentContentMacroShared",
                "FluentContentMacros"
            ]
        ),
        .target(
            name: "FluentContentMacroShared",
            dependencies: [
            ]
        ),

        .testTarget(
            name: "FluentContentMacroTests",
            dependencies: [
                "FluentContentMacro",
                "FluentContentMacros",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ],
            path: "Tests/FluentContentMacroTests"
        )
    ]
)
