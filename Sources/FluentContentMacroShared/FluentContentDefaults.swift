import Foundation

/// Configuration for the FluentContent macro's behavior.
/// You can modify these values to change the default settings for all @FluentContent usages in your project.
@_nonSendable
public enum FluentContentDefaults {
    /// If `true`, the generated `Content` struct uses `let` for its stored properties.
    /// If `false`, it uses `var`. Defaults to `true`.
    nonisolated(unsafe) public static var immutable = true

    /// Specifies which Fluent relationships should be included in the generated content.
    /// Relationship wrappers (such as `@Children`, `@Parent`, etc.) generate nested `...Content` types.
    /// Normal fields (e.g., `@Field`, `@ID`) are always included unless explicitly ignored with `@FluentContentIgnore`.
    /// Defaults to `.children`.
    nonisolated(unsafe) public static var includeRelations: IncludeRelations = .children

    /// The desired access level for the generated `Content` struct and `toContent()` method.
    /// Defaults to `.public`, but you can specify `.internal`, `.fileprivate`, or `.private` to restrict visibility.
    nonisolated(unsafe) public static var accessLevel: AccessLevel = .public

    /// The protocols that the generated content should conform to.
    /// Defaults to all available protocols (Equatable, Hashable, Sendable).
    nonisolated(unsafe) public static var conformances: ContentConformances = .all
}
