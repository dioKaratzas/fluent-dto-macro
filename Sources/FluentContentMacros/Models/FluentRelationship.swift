import Foundation
import FluentContentMacroShared

/// Represents all possible Fluent relationship property wrappers
enum FluentRelationship: String, CaseIterable {
    case parent = "Parent"
    case optionalParent = "OptionalParent"
    case children = "Children"
    case optionalChild = "OptionalChild"
    case siblings = "Siblings"

    /// Returns relationship wrappers based on the IncludedWrappers case
    static func wrappers(for includedWrappers: IncludedWrappers) -> [String] {
        switch includedWrappers {
        case .parent:
            return [FluentRelationship.parent.rawValue, FluentRelationship.optionalParent.rawValue]
        case .children:
            return [FluentRelationship.children.rawValue, FluentRelationship.optionalChild.rawValue, FluentRelationship.siblings.rawValue]
        case .both:
            return FluentRelationship.allCases.map(\.rawValue)
        }
    }
}
