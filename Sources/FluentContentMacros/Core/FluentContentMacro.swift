import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin

/**
 A macro that generates a content representation of your Fluent model.

 This macro provides two main functionalities:
 1. Generates a `...Content` struct as a "peer" declaration that can be used for API responses
 2. Adds a `toContent()` method via extension to easily convert model instances to their content representation

 ## Features
 - Automatically includes normal fields (e.g. `@Field`, `@ID`)
 - Optionally includes relationship wrappers (e.g. `@Parent`, `@Children`) based on `includeRelations`
 - Supports marking fields to ignore with `@FluentContentIgnore`
 - Configurable mutability with `immutable` parameter
 - Customizable access level

 ## Parameters
 - **immutable**: If `true`, the generated `Content` struct uses `let` for its stored properties.
   If `false`, it uses `var`. Defaults to `true`.
 - **includeRelations**: Specifies which Fluent property wrappers should be transformed into nested content.
   Relationship wrappers (such as `@Children`, `@Parent`, etc.) generate nested `...Content` types.
   Normal fields (e.g., `@Field`, `@ID`) are always included unless explicitly ignored with `@FluentContentIgnore`.
   Defaults to `.children`.
 - **accessLevel**: The desired access level for the generated `Content` struct and `toContent()` method.
   Defaults to `.public`, but you can specify `.internal`, `.fileprivate`, or `.private` to restrict visibility.

 ## Example Usage
 ```swift
 @FluentContent(
    immutable: true,
    includeRelations: .children,
    accessLevel: .public
 )
 public final class User: Model {
     @ID(key: .id) public var id: UUID?
     @Field(key: "username") public var username: String
     @Children(for: \.$user) var posts: [Post]
 }

 // The macro auto-generates:
 public struct UserContent: Content, Equatable {
     public let id: UUID?
     public let username: String
     public let posts: [PostContent]
 }

 extension User {
     public func toContent() -> UserContent {
         .init(
             id: id,
             username: username,
             posts: posts.map { $0.toContent() }
         )
     }
 }
 ```
 */
public struct FluentContentMacro: PeerMacro, ExtensionMacro {
    // MARK: - Peer Macro: Generate "...Content" struct
    /// Expands the macro to generate a peer content struct that mirrors the model's structure.
    /// - Parameters:
    ///   - node: The attribute syntax node representing the macro
    ///   - declaration: The declaration the macro is attached to
    ///   - context: The macro expansion context
    /// - Returns: An array of declarations to be added as peers
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Parse the macro arguments => (immutable, includeRelations => [String])
        let (isImmutable, includeRelations, accessLevel) = try MacroArgumentParser.parseMacroArguments(from: node)

        // Identify class or struct
        let (modelName, members, modelAccess) = MacroArgumentParser.extractModelDeclInfo(declaration: declaration)
        guard !modelName.isEmpty else {
            return []
        }

        let structAccess = accessLevel.resolvedAccessLevel(modelAccess: modelAccess)

        // Build the "Content" struct
        let contentName = "\(modelName)Content"
        let props = PropertyExtractor.extractProperties(from: members, includeRelations: includeRelations)
        let structDecl = ContentStructBuilder.buildContentStruct(
            name: contentName,
            properties: props,
            access: structAccess,
            isImmutable: isImmutable
        )

        return [DeclSyntax(stringLiteral: structDecl)]
    }

    // MARK: - Extension Macro: Generate `toContent()` Method
    /// Expands the macro to add a `toContent()` method to the model.
    /// - Parameters:
    ///   - node: The attribute syntax node representing the macro
    ///   - declaration: The declaration group the macro is attached to
    ///   - type: The type to extend
    ///   - protocols: The protocols to conform to
    ///   - context: The macro expansion context
    /// - Returns: An array of extension declarations
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        let (_, includeRelations, accessLevel) = try MacroArgumentParser.parseMacroArguments(from: node)
        let (modelName, members, modelAccess) = MacroArgumentParser.extractModelDeclInfo(declaration: declaration)
        guard !modelName.isEmpty else {
            return []
        }

        let methodAccess = accessLevel.resolvedAccessLevel(modelAccess: modelAccess)
        let props = PropertyExtractor.extractProperties(from: members, includeRelations: includeRelations)
        let contentName = "\(modelName)Content"

        let methodDecl = ContentStructBuilder.buildToContentMethod(
            properties: props,
            contentName: contentName,
            access: methodAccess
        )

        let extDecl = try ExtensionDeclSyntax("extension \(raw: modelName) {\n\(raw: methodDecl)\n}")
        return [extDecl]
    }
}
