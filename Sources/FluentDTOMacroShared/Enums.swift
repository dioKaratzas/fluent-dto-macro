import Foundation

/// Specifies which Fluent relationships should be included in the generated DTO.
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

/// Defines the access level for the generated `DTO` struct and `toDTO()` method.
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

/// Defines which protocols the generated DTO should conform to
public struct DTOConformances: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Conform to Equatable protocol
    public static let equatable = DTOConformances(rawValue: 1 << 0)

    /// Conform to Hashable protocol
    public static let hashable = DTOConformances(rawValue: 1 << 1)

    /// Conform to Sendable protocol
    public static let sendable = DTOConformances(rawValue: 1 << 2)

    /// Conform to all available protocols (Equatable, Hashable, Sendable)
    public static let all: DTOConformances = [.equatable, .hashable, .sendable]

    /// Only conform to CodableDTO (minimum requirement)
    public static let none: DTOConformances = []
}
