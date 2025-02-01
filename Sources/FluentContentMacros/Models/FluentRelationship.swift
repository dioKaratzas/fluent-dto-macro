import Foundation
import FluentContentMacroShared

/// Represents all possible Fluent relationship property wrappers
enum FluentRelationship: String, CaseIterable {
    case parent = "Parent"
    case optionalParent = "OptionalParent"
    case children = "Children"
    case optionalChild = "OptionalChild"
    case siblings = "Siblings"

    /// Returns relationship wrappers based on the IncludeRelations case
    static func wrappers(for includeRelations: IncludeRelations) -> [String] {
        switch includeRelations {
        case .parent:
            [FluentRelationship.parent.rawValue, FluentRelationship.optionalParent.rawValue]
        case .children:
            [FluentRelationship.children.rawValue, FluentRelationship.optionalChild.rawValue, FluentRelationship.siblings.rawValue]
        case .both:
            FluentRelationship.allCases.map(\.rawValue)
        }
    }
}
