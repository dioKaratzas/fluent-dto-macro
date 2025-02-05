import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxBuilder
import SwiftCompilerPlugin

/**
 A macro that generates a content representation of your Fluent model.

 This macro provides two main functionalities:
 1. Generates a peer type with the name pattern `{ModelName}{Suffix}` (e.g., `UserContent` by default)
 2. Adds a conversion method named `to{Suffix}()` (e.g., `toContent()` by default) via extension

 ## Features
 - Automatically includes normal fields (e.g. `@Field`, `@ID`)
 - Optionally includes relationship wrappers (e.g. `@Parent`, `@Children`) based on `includeRelations`
 - Supports marking fields to ignore with `@FluentContentIgnore`
 - Configurable mutability with `immutable` parameter
 - Customizable access level
 - Dynamic naming based on `contentSuffix`

 ## Parameters
 - **immutable**: If `true`, the generated type uses `let` for its stored properties.
   If `false`, it uses `var`. Defaults to `true`.
 - **includeRelations**: Specifies which Fluent property wrappers should be transformed into nested types.
   Relationship wrappers (such as `@Children`, `@Parent`, etc.) generate nested types with the same suffix.
   Normal fields (e.g., `@Field`, `@ID`) are always included unless explicitly ignored with `@FluentContentIgnore`.
   Defaults to `.children`.
 - **accessLevel**: The desired access level for the generated type and conversion method.
   Defaults to `.public`, but you can specify `.internal`, `.fileprivate`, or `.private` to restrict visibility.
 - **conformances**: The protocols that the generated type should conform to.
   Defaults to all available protocols (Equatable, Hashable, Sendable).
 - **contentSuffix**: The suffix to use for generated types and conversion methods.
   For example, if set to "DTO", a User model would generate:
   - A UserDTO struct
   - A toDTO() conversion method
   Defaults to FluentContentDefaults.contentSuffix.

 ## Example Usage
 ```swift
 // Default behavior
 @FluentContent
 public final class User: Model {
     @ID(key: .id) public var id: UUID?
     @Field(key: "username") public var username: String
     @Children(for: \.$user) var posts: [Post]
 }

 // Generates:
 public struct UserContent: CodableContent, Equatable, Hashable, Sendable { ... }
 extension User { public func toContent() -> UserContent { ... } }

 // Custom suffix example
 @FluentContent(contentSuffix: "DTO")
 public final class User: Model {
     @ID(key: .id) public var id: UUID?
     @Field(key: "username") public var username: String
 }

 // Generates:
 public struct UserDTO: CodableContent, Equatable, Hashable, Sendable { ... }
 extension User { public func toDTO() -> UserDTO { ... } }
 ```
 */
public struct FluentContentMacro: PeerMacro, ExtensionMacro {
    // MARK: - Peer Macro: Generate content struct
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
        let (isImmutable, includeRelations, accessLevel, conformances, contentSuffix) = try MacroArgumentParser.parseMacroArguments(from: node)

        let (modelName, members, modelAccess) = MacroArgumentParser.extractModelDeclInfo(declaration: declaration)
        guard !modelName.isEmpty else {
            return []
        }

        let structAccess = accessLevel.resolvedAccessLevel(modelAccess: modelAccess)
        let contentName = "\(modelName)\(contentSuffix)"
        let props = PropertyExtractor.extractProperties(from: members, includeRelations: includeRelations)
        let structDecl = ContentStructBuilder.buildContentStruct(
            name: contentName,
            properties: props,
            access: structAccess,
            isImmutable: isImmutable,
            conformances: conformances,
            contentSuffix: contentSuffix
        )

        return [DeclSyntax(stringLiteral: structDecl)]
    }

    // MARK: - Extension Macro: Generate conversion method
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
        let (_, includeRelations, accessLevel, _, contentSuffix) = try MacroArgumentParser.parseMacroArguments(from: node)
        let (modelName, members, modelAccess) = MacroArgumentParser.extractModelDeclInfo(declaration: declaration)
        guard !modelName.isEmpty else {
            return []
        }

        let methodAccess = accessLevel.resolvedAccessLevel(modelAccess: modelAccess)
        let props = PropertyExtractor.extractProperties(from: members, includeRelations: includeRelations)
        let contentName = "\(modelName)\(contentSuffix)"

        // Generate method name based on suffix (e.g., toDTO() for DTO suffix)
        let methodName = "to\(contentSuffix)"

        let methodDecl = ContentStructBuilder.buildConversionMethod(
            properties: props,
            contentName: contentName,
            methodName: methodName,
            access: methodAccess
        )

        let extDecl = try ExtensionDeclSyntax("extension \(raw: modelName) {\n\(raw: methodDecl)\n}")
        return [extDecl]
    }
}
