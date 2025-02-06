// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "fluent-dto-macro",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "FluentDTOMacro",
            targets: ["FluentDTOMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "601.0.0"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing", branch: "main"),
    ],
    targets: [
        // Macro implementation
        .macro(
            name: "FluentDTOMacroPlugin",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "FluentDTOMacroShared"
            ]
        ),

        // Library that exposes the macro
        .target(
            name: "FluentDTOMacro",
            dependencies: [
                "FluentDTOMacroPlugin",
                "FluentDTOMacroShared"
            ]
        ),

        // Shared types between the macro and the library
        .target(
            name: "FluentDTOMacroShared"
        ),

        // Test target
        .testTarget(
            name: "FluentDTOMacroTests",
            dependencies: [
                "FluentDTOMacro",
                "FluentDTOMacroPlugin",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
