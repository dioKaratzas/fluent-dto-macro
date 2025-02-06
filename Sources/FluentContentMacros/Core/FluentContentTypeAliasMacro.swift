import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import FluentContentMacroShared

public struct FluentContentTypeAliasMacro: DeclarationMacro {
    public static func expansion(
        of node: some FreestandingMacroExpansionSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Get the declaration this macro is attached to
        guard let declaration = node.parent?.parent?.as(ClassDeclSyntax.self) else {
            return []
        }
        
        let modelName = declaration.name.text
        guard !modelName.isEmpty else {
            return []
        }
        
        // Find the @FluentContent attribute to get the contentSuffix
        let contentSuffix = declaration.attributes.compactMap { attr -> String? in
            guard let attr = attr.as(AttributeSyntax.self),
                  attr.attributeName.description == "FluentContent" else {
                return nil
            }
            
            if let args = attr.arguments?.as(LabeledExprListSyntax.self) {
                for arg in args where arg.label?.text == "contentSuffix" {
                    if let stringLit = arg.expression.as(StringLiteralExprSyntax.self) {
                        return stringLit.segments.first?.description ?? FluentContentDefaults.contentSuffix
                    }
                }
            }
            return FluentContentDefaults.contentSuffix
        }.first ?? FluentContentDefaults.contentSuffix
        
        // Generate the typealias with the correct suffix
        let typeName = "\(modelName)\(contentSuffix)"
        let typealiasDecl = "public typealias \(typeName) = \(modelName).\(typeName)"
        
        return [DeclSyntax(stringLiteral: typealiasDecl)]
    }
} 