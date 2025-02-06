import SwiftSyntax
import SwiftSyntaxBuilder
import FluentDTOMacroShared

/// Parser for macro arguments and model declarations.
///
/// This struct provides utilities for parsing macro arguments and extracting
/// information from model declarations in the macro system.
struct MacroArgumentParser {
    /// Configuration options parsed from macro arguments
    typealias MacroConfig = (isImmutable: Bool, includeRelations: [String], accessLevel: AccessLevel, conformances: DTOConformances)

    /// Information about the model declaration being processed
    typealias ModelInfo = (name: String, members: MemberBlockSyntax?, accessLevel: String)

    /// Parses the macro arguments to extract configuration options.
    /// - Parameter attr: The attribute syntax node to parse
    /// - Returns: A MacroConfig containing the parsed configuration
    static func parseMacroArguments(
        from attr: AttributeSyntax
    ) throws -> MacroConfig {
        var isImmutable = FluentDTODefaults.immutable
        var relationNames = wrappersForCase(FluentDTODefaults.includeRelations)
        var accessLevel = FluentDTODefaults.accessLevel
        var conformances = FluentDTODefaults.conformances

        guard let args = attr.arguments?.as(LabeledExprListSyntax.self) else {
            return (isImmutable, relationNames, accessLevel, conformances)
        }

        for arg in args {
            let label = arg.label?.text
            let expr = arg.expression

            if label == "immutable",
               let boolLit = expr.as(BooleanLiteralExprSyntax.self) {
                isImmutable = boolLit.literal.text == "true"
            } else if label == "includeRelations" {
                let parsed = try parseIncludeRelations(expr)
                relationNames = parsed
            } else if label == "accessLevel" {
                if let memAccess = expr.as(MemberAccessExprSyntax.self) {
                    let rawCaseName = memAccess.declName.baseName.text
                    if let cAccess = AccessLevel(rawValue: rawCaseName) {
                        accessLevel = cAccess
                    }
                }
            } else if label == "conformances" {
                conformances = try parseConformances(expr)
            }
        }

        return (isImmutable, relationNames, accessLevel, conformances)
    }

    /// Extracts information about a model declaration.
    /// - Parameter declaration: The declaration to analyze
    /// - Returns: A ModelInfo containing the model's name, members, and access level
    static func extractModelDeclInfo(
        declaration: some DeclSyntaxProtocol
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

    /// Extracts information about a model declaration.
    /// - Parameter declaration: The declaration to analyze
    /// - Returns: A ModelInfo containing the model's name, members, and access level
    static func extractModelDeclInfo(
        declaration: some DeclGroupSyntax
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

    private static func parseIncludeRelations(
        _ expr: some ExprSyntaxProtocol
    ) throws -> [String] {
        let relation: IncludeRelations = {
            if let memAccess = expr.as(MemberAccessExprSyntax.self) {
                let baseName = memAccess.declName.baseName.text
                switch baseName {
                case "parent": return .parent
                case "children": return .children
                case "all": return .all
                case "none": return .none
                default: return .none
                }
            } else if let arrayExpr = expr.as(ArrayExprSyntax.self) {
                var relations: IncludeRelations = []
                for element in arrayExpr.elements {
                    if let memAccess = element.expression.as(MemberAccessExprSyntax.self) {
                        switch memAccess.declName.baseName.text {
                        case "parent": relations.insert(.parent)
                        case "children": relations.insert(.children)
                        case "all": return .all
                        case "none": return .none
                        default: break
                        }
                    }
                }
                return relations
            }
            return .none
        }()

        return wrappersForCase(relation)
    }

    private static func wrappersForCase(_ choice: IncludeRelations) -> [String] {
        FluentRelationship.wrappers(for: choice)
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

    private static func parseConformances(_ expr: some ExprSyntaxProtocol) throws -> DTOConformances {
        if let arrayExpr = expr.as(ArrayExprSyntax.self) {
            var conformances: DTOConformances = []
            for element in arrayExpr.elements {
                if let memAccess = element.expression.as(MemberAccessExprSyntax.self) {
                    switch memAccess.declName.baseName.text {
                    case "equatable": conformances.insert(.equatable)
                    case "hashable": conformances.insert(.hashable)
                    case "sendable": conformances.insert(.sendable)
                    case "all": conformances = .all
                    case "none": conformances = .none
                    default: break
                    }
                }
            }
            return conformances
        } else if let memAccess = expr.as(MemberAccessExprSyntax.self) {
            let baseName = memAccess.declName.baseName.text
            switch baseName {
            case "equatable": return [.equatable]
            case "hashable": return [.hashable]
            case "sendable": return [.sendable]
            case "all": return .all
            case "none": return .none
            default: return .none
            }
        }
        return .all // Default to all if parsing fails
    }
}
