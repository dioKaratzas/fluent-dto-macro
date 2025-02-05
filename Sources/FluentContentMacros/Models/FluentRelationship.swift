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
        var wrappers: [String] = []

        if includeRelations.contains(.parent) {
            wrappers += [FluentRelationship.parent.rawValue, FluentRelationship.optionalParent.rawValue]
        }

        if includeRelations.contains(.children) {
            wrappers += [FluentRelationship.children.rawValue, FluentRelationship.optionalChild.rawValue, FluentRelationship.siblings.rawValue]
        }

        return wrappers
    }
}
