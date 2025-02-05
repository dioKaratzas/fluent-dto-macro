import Foundation

/// Specifies which Fluent relationships should be included in the generated type.
public struct IncludeRelations: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Includes parent relationships (e.g., `@Parent`, `@OptionalParent`).
    public static let parent = IncludeRelations(rawValue: 1 << 0)

    /// Includes child relationships (e.g., `@Children`, `@OptionalChild`, `@Siblings`).
    public static let children = IncludeRelations(rawValue: 1 << 1)

    /// Includes both parent and child relationships.
    public static let all: IncludeRelations = [.parent, .children]

    /// Includes no relationships.
    public static let none: IncludeRelations = []
}

/// Defines the access level for the generated type and conversion method.
public enum AccessLevel: String, Sendable {
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

/// Defines which protocols the generated content should conform to
public struct ContentConformances: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Conform to Equatable protocol
    public static let equatable = ContentConformances(rawValue: 1 << 0)

    /// Conform to Hashable protocol
    public static let hashable = ContentConformances(rawValue: 1 << 1)

    /// Conform to Sendable protocol
    public static let sendable = ContentConformances(rawValue: 1 << 2)

    /// Conform to all available protocols (Equatable, Hashable, Sendable)
    public static let all: ContentConformances = [.equatable, .hashable, .sendable]

    /// Only conform to CodableContent (minimum requirement)
    public static let none: ContentConformances = []
}
