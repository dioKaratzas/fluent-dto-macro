import Foundation

/// Specifies which Fluent property wrappers should be included in the generated content.
public enum IncludedWrappers {
    /// Includes only parent relationships (e.g., `@Parent`, `@OptionalParent`).
    case parent

    /// Includes only child relationships (e.g., `@Children`, `@OptionalChild`, `@Siblings`).
    case children

    /// Includes both parent and child relationships.
    case both
}

/// Defines the access level for the generated `Content` struct and `toContent()` method.
public enum AccessLevel: String {
    /// Matches the access level of the model.
    case matchModel

    /// Public access level.
    case `public`

    /// Internal access level.
    case `internal`

    /// File-private access level.
    case `fileprivate`

    /// Private access level.
    case `private`
}