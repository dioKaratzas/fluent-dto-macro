import SwiftSyntax
import SwiftSyntaxBuilder
import FluentContentMacroShared

/// Parser for macro arguments and model declarations.
///
/// This struct provides utilities for parsing macro arguments and extracting
/// information from model declarations in the macro system.
struct MacroArgumentParser {
    /// Configuration options parsed from macro arguments
    typealias MacroConfig = (isImmutable: Bool, includedWrappers: [String], accessLevel: AccessLevel)

    /// Information about the model declaration being processed
    typealias ModelInfo = (name: String, members: MemberBlockSyntax?, accessLevel: String)

    /// Parses the macro arguments to extract configuration options.
    /// - Parameter attr: The attribute syntax node to parse
    /// - Returns: A MacroConfig containing the parsed configuration
    static func parseMacroArguments(
        from attr: AttributeSyntax
    ) throws -> MacroConfig {
        var isImmutable = DefaultConfig.immutable
        var wrapperNames = wrappersForCase(DefaultConfig.includedWrappers)
        var accessLevel = DefaultConfig.accessLevel

        guard let args = attr.arguments?.as(LabeledExprListSyntax.self) else {
            return (isImmutable, wrapperNames, accessLevel)
        }

        for arg in args {
            let label = arg.label?.text
            let expr = arg.expression

            if label == "immutable",
               let boolLit = expr.as(BooleanLiteralExprSyntax.self) {
                isImmutable = boolLit.literal.text == "true"
            } else if label == "includedWrappers" {
                let parsed = try parseIncludedWrappers(expr)
                wrapperNames = parsed
            } else if label == "accessLevel" {
                if let memAccess = expr.as(MemberAccessExprSyntax.self) {
                    let rawCaseName = memAccess.declName.baseName.text
                    if let cAccess = AccessLevel(rawValue: rawCaseName) {
                        accessLevel = cAccess
                    }
                }
            }
        }

        return (isImmutable, wrapperNames, accessLevel)
    }

    /// Extracts information about a model declaration.
    /// - Parameter declaration: The declaration to analyze
    /// - Returns: A ModelInfo containing the model's name, members, and access level
    static func extractModelDeclInfo(
        declaration: some SwiftSyntax.DeclSyntaxProtocol
    ) -> ModelInfo {
        if let classDecl = declaration.as(ClassDeclSyntax.self) {
            let access = findAccessLevel(in: classDecl.modifiers)
            return (classDecl.name.text, classDecl.memberBlock, access)
        }
        if let structDecl = declaration.as(StructDeclSyntax.self) {
            let access = findAccessLevel(in: structDecl.modifiers)
            return (structDecl.name.text, structDecl.memberBlock, access)
        }

        return ("", nil, "")
    }

    private static func parseIncludedWrappers(
        _ expr: some ExprSyntaxProtocol
    ) throws -> [String] {
        if let memAccess = expr.as(MemberAccessExprSyntax.self) {
            let caseName = memAccess.declName.baseName.text
            switch caseName {
            case "parent":
                return wrappersForCase(.parent)
            case "children":
                return wrappersForCase(.children)
            case "custom":
                if let fnCall = memAccess.parent?.as(FunctionCallExprSyntax.self),
                   let firstArg = fnCall.arguments.first?.expression.as(ArrayExprSyntax.self) {
                    return firstArg.elements.compactMap {
                        $0.expression.as(StringLiteralExprSyntax.self)?.segments.first?.description
                    }
                }
                return []
            default:
                return wrappersForCase(.parent)
            }
        }

        if let fnCall = expr.as(FunctionCallExprSyntax.self) {
            let calledName = fnCall.calledExpression.description.trimmingCharacters(in: .whitespacesAndNewlines)
            if calledName.hasSuffix("parent") {
                return wrappersForCase(.parent)
            } else if calledName.hasSuffix("children") {
                return wrappersForCase(.children)
            } else if calledName.hasSuffix("custom") {
                if let firstArg = fnCall.arguments.first?.expression.as(ArrayExprSyntax.self) {
                    return firstArg.elements.compactMap {
                        $0.expression.as(StringLiteralExprSyntax.self)?.segments.first?.description
                    }
                }
            }
        }

        return wrappersForCase(.parent)
    }

    private static func wrappersForCase(_ choice: IncludedWrappers) -> [String] {
        switch choice {
        case .parent:
            ["Parent", "OptionalParent"]
        case .children:
            ["Children", "OptionalChild", "Siblings"]
        case let .custom(arr):
            arr
        }
    }

    private static func findAccessLevel(in modifiers: DeclModifierListSyntax?) -> String {
        guard let modifiers else {
            return "internal"
        }

        if modifiers.contains(where: { $0.name.text == "open" }) {
            return "public"
        }
        if modifiers.contains(where: { $0.name.text == "public" }) {
            return "public"
        }
        if modifiers.contains(where: { $0.name.text == "internal" }) {
            return "internal"
        }
        if modifiers.contains(where: { $0.name.text == "fileprivate" }) {
            return "fileprivate"
        }
        if modifiers.contains(where: { $0.name.text == "private" }) {
            return "private"
        }
        return "internal"
    }
}
