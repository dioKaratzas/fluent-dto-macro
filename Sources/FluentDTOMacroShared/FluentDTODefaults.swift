import Foundation

/// Configuration for the FluentDTO macro's behavior.
/// You can modify these values to change the default settings for all @FluentDTO usages in your project.
@_nonSendable
public enum FluentDTODefaults {
    /// If `true`, the generated `DTO` struct uses `let` for its stored properties.
    /// If `false`, it uses `var`. Defaults to `true`.
    nonisolated(unsafe) public static var immutable = true

    /// Specifies which Fluent relationships should be included in the generated DTO.
    /// Relationship wrappers (such as `@Children`, `@Parent`, etc.) generate nested `...DTO` types.
    /// Normal fields (e.g., `@Field`, `@ID`) are always included unless explicitly ignored with `@FluentDTOIgnore`.
    /// Defaults to `.children`.
    nonisolated(unsafe) public static var includeRelations: IncludeRelations = .children

    /// The desired access level for the generated `DTO` struct and `toDTO()` method.
    /// Defaults to `.public`, but you can specify `.internal`, `.fileprivate`, or `.private` to restrict visibility.
    nonisolated(unsafe) public static var accessLevel: AccessLevel = .public

    /// The protocols that the generated DTO should conform to.
    /// Defaults to all available protocols (Equatable, Hashable, Sendable).
    nonisolated(unsafe) public static var conformances: DTOConformances = .all
}
