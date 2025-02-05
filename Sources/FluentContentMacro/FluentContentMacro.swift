import FluentContentMacroShared

/**
  A macro that generates a `...Content` struct as a peer to your Fluent model (class or struct) and
  an extension that adds a `toContent()` method returning the generated struct.

  ### Parameters

  - **immutable**:
  If `true`, the generated `Content` struct uses `let` for its stored properties.
  If `false`, it uses `var`. Defaults to `true`.

  - **includeRelations**:
  Specifies which Fluent relationships should be transformed into nested content.
  Relationship wrappers (such as `@Children`, `@Parent`, etc.) generate nested `...Content` types.
  Normal fields (e.g., `@Field`, `@ID`) are always included unless explicitly ignored with `@FluentContentIgnore`.
  Defaults to `.children`.

  - **accessLevel**:
  The desired access level for the generated `Content` struct and `toContent()` method.
  Defaults to `.public`, but you can specify `.internal`, `.fileprivate`, or `.private` to restrict visibility.

  - **conformances**:
  The protocols that the generated content should conform to.
  Defaults to all available protocols (Equatable, Hashable, Sendable).

  ### Usage Example

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
 public struct UserContent: Equatable { ... }
 extension User { public func toContent() -> UserContent { ... } }
  */
@attached(peer, names: suffixed(Content))
@attached(extension, names: named(toContent))
public macro FluentContent(
    /// If `true`, the generated `Content` struct uses `let` instead of `var`.
    immutable: Bool = FluentContentDefaults.immutable,
    /// Specifies which Fluent relationships to include in the generated content.
    includeRelations: IncludeRelations = FluentContentDefaults.includeRelations,
    /// The desired access level for the generated `Content` struct and `toContent()` method.
    accessLevel: AccessLevel = FluentContentDefaults.accessLevel,
    /// The protocols that the generated content should conform to.
    /// Defaults to all available protocols (Equatable, Hashable, Sendable).
    conformances: ContentConformances = FluentContentDefaults.conformances
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
