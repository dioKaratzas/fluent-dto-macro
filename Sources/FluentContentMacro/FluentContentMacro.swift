import FluentContentMacroShared

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

 - **immutable**:
 If `true`, the generated struct uses `let` for its stored properties.
 If `false`, it uses `var`. Defaults to `true`.

 - **includeRelations**:
 Specifies which Fluent property wrappers should be transformed into nested content.
 Relationship wrappers (such as `@Children`, `@Parent`, etc.) generate nested types.
 Normal fields (e.g., `@Field`, `@ID`) are always included unless explicitly ignored with `@FluentContentIgnore`.
 Defaults to `.children`.

 - **accessLevel**:
 The desired access level for the generated struct and conversion method.
 Defaults to `.public`, but you can specify `.internal`, `.fileprivate`, or `.private` to restrict visibility.

 - **conformances**:
 The protocols that the generated type should conform to.
 Defaults to all available protocols (Equatable, Hashable, Sendable).

 - **contentSuffix**:
 The suffix to use for the generated type and conversion method.
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
@attached(member, names: arbitrary)
public macro FluentContent(
    /// If `true`, the generated struct uses `let` instead of `var`.
    immutable: Bool = FluentContentDefaults.immutable,
    /// Specifies which Fluent relationships to include in the generated content.
    includeRelations: IncludeRelations = FluentContentDefaults.includeRelations,
    /// The desired access level for the generated struct and conversion method.
    accessLevel: AccessLevel = FluentContentDefaults.accessLevel,
    /// The protocols that the generated type should conform to.
    /// Defaults to all available protocols (Equatable, Hashable, Sendable).
    conformances: ContentConformances = FluentContentDefaults.conformances,
    /// The suffix to use for the generated struct and conversion method.
    /// For example, if set to "DTO", a User model would generate a UserDTO struct and toDTO() method.
    /// Defaults to FluentContentDefaults.contentSuffix.
    contentSuffix: String = FluentContentDefaults.contentSuffix
) = #externalMacro(
    module: "FluentContentMacros",
    type: "FluentContentMacro"
)

/**
 A macro that excludes a property from the `...Content` struct generated by `@FluentContent`.
 Useful for fields that should not be exposed, such as IDs, passwords, or tokens.

 ### Example

 ```swift
 public final class User: Model {
    @ID(key: .id) public var id: UUID?

    @FluentContentIgnore
    @Field(key: "password_hash") public var passwordHash: String

    @Field(key: "username") public var username: String
 }
 */
@attached(accessor)
public macro FluentContentIgnore() = #externalMacro(
    module: "FluentContentMacros",
    type: "FluentContentIgnoreMacro"
)
