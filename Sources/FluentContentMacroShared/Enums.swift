import Foundation

/// Specifies which Fluent property wrappers should be included in the generated content.
public enum IncludedWrappers {
    /// Includes only parent relationships (e.g., `@Parent`, `@OptionalParent`).
    case parent

    /// Includes only child relationships (e.g., `@Children`, `@OptionalChild`, `@Siblings`).
    case children

    /**
     Specifies a custom array of property wrapper names.

     Example:

     ```swift
     @FluentContent(includedWrappers: .custom(["Parent", "Children"]))
     ```

     - Parameter names: An array of Fluent property wrapper names to include.
     */
    case custom([String])
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

    public func resolvedAccessLevel(modelAccess: String) -> String {
        switch self {
        case .matchModel:
            modelAccess
        case .public:
            "public"
        case .internal:
            "internal"
        case .fileprivate:
            "fileprivate"
        case .private:
            "private"
        }
    }
}
