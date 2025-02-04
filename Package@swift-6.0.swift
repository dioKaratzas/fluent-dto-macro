// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "FluentContentMacro",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "FluentContentMacro",
            targets: ["FluentContentMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax", "509.0.0" ..< "601.0.0"),
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
    ],
    swiftLanguageModes: [.v6]
)
