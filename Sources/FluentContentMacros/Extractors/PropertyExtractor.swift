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
    /// - Parameters:
    ///   - members: The member block to analyze
    ///   - includeRelations: List of wrapper names to include
    /// - Returns: Array of property information
    static func extractProperties(
        from members: MemberBlockSyntax?,
        includeRelations: [String]
    ) -> [PropertyInfo] {
        guard let members else {
            return []
        }

        return members.members
            .filter { member in
                guard
                    let varDecl = member.decl.as(VariableDeclSyntax.self),
                    let binding = varDecl.bindings.first,
                    let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
                    let typeAnno = binding.typeAnnotation?.type else {
                    return false
                }

                let attributeWrappers: [String] = varDecl.attributes.compactMap { element in
                    guard
                        let attrSyntax = element.as(AttributeSyntax.self),
                        let identType = attrSyntax.attributeName.as(IdentifierTypeSyntax.self) else {
                        return nil
                    }
                    return identType.name.text
                }

                if attributeWrappers.contains("FluentContentIgnore") {
                    return false
                }

                let propertyRelationships = attributeWrappers.filter { knownRelationships.contains($0) }
                let hasRelationship = !propertyRelationships.isEmpty
                
                // Skip if this property has a relationship that's not included
                if hasRelationship && !propertyRelationships.contains(where: includeRelations.contains) {
                    return false
                }

                return true
            }
            .map { member in
                let varDecl = member.decl.as(VariableDeclSyntax.self)!
                let binding = varDecl.bindings.first!
                let pattern = binding.pattern.as(IdentifierPatternSyntax.self)!
                let typeAnno = binding.typeAnnotation!.type

                let attributeWrappers: [String] = varDecl.attributes.compactMap { element in
                    guard
                        let attrSyntax = element.as(AttributeSyntax.self),
                        let identType = attrSyntax.attributeName.as(IdentifierTypeSyntax.self) else {
                        return nil
                    }
                    return identType.name.text
                }

                let propertyRelationships = attributeWrappers.filter { knownRelationships.contains($0) }
                let hasRelationship = !propertyRelationships.isEmpty

                let (baseType, isOpt, isArr) = TypeUtils.unwrapTypeLayers(typeAnno)

                return (
                    name: pattern.identifier.text,
                    type: baseType,
                    isOptional: isOpt,
                    isArray: isArr,
                    isRelationship: hasRelationship
                )
            }
    }
}
