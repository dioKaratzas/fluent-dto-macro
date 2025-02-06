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
public struct FluentContentMacro: MemberMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingMembersOf declaration: some SwiftSyntax.DeclGroupSyntax,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let (isImmutable, includeRelations, accessLevel, conformances, contentSuffix) = try MacroArgumentParser.parseMacroArguments(from: node)

        let (modelName, members, modelAccess) = MacroArgumentParser.extractModelDeclInfo(declaration: declaration)
        guard !modelName.isEmpty else {
            return []
        }

        let structAccess = accessLevel.resolvedAccessLevel(modelAccess: modelAccess)
        let contentName = "\(contentSuffix)"
        let props = PropertyExtractor.extractProperties(from: members, includeRelations: includeRelations)
        
        // Build the nested content struct
        let structDecl = ContentStructBuilder.buildContentStruct(
            name: contentName,
            properties: props,
            access: structAccess,
            isImmutable: isImmutable,
            conformances: conformances,
            contentSuffix: contentSuffix
        )

        // Build the conversion method
        let methodDecl = ContentStructBuilder.buildConversionMethod(
            properties: props,
            contentName: contentName,
            methodName: "toContent",
            access: structAccess
        )

        return [
            DeclSyntax(stringLiteral: structDecl),
            DeclSyntax(stringLiteral: methodDecl)
        ]
    }
}
