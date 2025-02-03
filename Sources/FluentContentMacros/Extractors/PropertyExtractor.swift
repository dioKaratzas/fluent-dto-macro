import SwiftSyntax
import SwiftSyntaxBuilder
import FluentContentMacroShared

/// Extracts and analyzes properties from Swift declarations
struct PropertyExtractor {
    /// Known Fluent relationship property wrappers
    static var knownRelationships: [String] {
        FluentRelationship.allCases.map(\.rawValue)
    }

    /// Information about a property extracted from a declaration
    typealias PropertyInfo = (name: String, type: String, isOptional: Bool, isArray: Bool, isRelationship: Bool)

    /// Extracts properties from a member block, filtering based on included wrappers
    static func extractProperties(
        from members: MemberBlockSyntax?,
        includeRelations: [String]
    ) -> [PropertyInfo] {
        guard let members else {
            return []
        }

        return members.members
            .filter { shouldIncludeProperty($0, includeRelations: includeRelations) }
            .map(extractPropertyInfo)
    }

    // MARK: - Private Helpers

    /// Determines if a property should be included in the generated content
    private static func shouldIncludeProperty(
        _ member: MemberBlockItemSyntax,
        includeRelations: [String]
    ) -> Bool {
        guard let propertyDecl = extractPropertyDeclaration(from: member) else {
            return false
        }

        let attributeWrappers = extractAttributeWrappers(from: propertyDecl.decl.attributes)

        // Skip if property is marked to be ignored
        if attributeWrappers.contains("FluentContentIgnore") {
            return false
        }

        // Check relationship compatibility
        let propertyRelationships = attributeWrappers.filter { knownRelationships.contains($0) }
        let hasRelationship = !propertyRelationships.isEmpty

        // Skip if property has a relationship that's not included
        if hasRelationship, !propertyRelationships.contains(where: includeRelations.contains) {
            return false
        }

        return true
    }

    /// Extracts property declaration from a member syntax
    private static func extractPropertyDeclaration(
        from member: MemberBlockItemSyntax
    ) -> (decl: VariableDeclSyntax, binding: PatternBindingSyntax)? {
        guard
            let varDecl = member.decl.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first,
            let _ = binding.pattern.as(IdentifierPatternSyntax.self),
            let _ = binding.typeAnnotation?.type else {
            return nil
        }
        return (varDecl, binding)
    }

    /// Extracts attribute wrappers from property attributes
    private static func extractAttributeWrappers(
        from attributes: AttributeListSyntax
    ) -> [String] {
        attributes.compactMap { element in
            guard
                let attrSyntax = element.as(AttributeSyntax.self),
                let identType = attrSyntax.attributeName.as(IdentifierTypeSyntax.self) else {
                return nil
            }
            return identType.name.text
        }
    }

    /// Extracts property information from a member declaration
    private static func extractPropertyInfo(
        _ member: MemberBlockItemSyntax
    ) -> PropertyInfo {
        let (varDecl, binding) = extractPropertyDeclaration(from: member)!
        let pattern = binding.pattern.as(IdentifierPatternSyntax.self)!
        let typeAnno = binding.typeAnnotation!.type

        let attributeWrappers = extractAttributeWrappers(from: varDecl.attributes)
        let hasRelationship = !attributeWrappers.filter { knownRelationships.contains($0) }.isEmpty

        let (baseType, isOptional, isArray) = TypeUtils.unwrapTypeLayers(typeAnno)

        return (
            name: pattern.identifier.text,
            type: baseType,
            isOptional: isOptional,
            isArray: isArray,
            isRelationship: hasRelationship
        )
    }
}
