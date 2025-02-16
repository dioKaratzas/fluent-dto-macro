import SwiftSyntax
import SwiftSyntaxBuilder
import FluentDTOMacroShared

struct DTOStructBuilder {
    static func buildDTOStruct(
        name: String,
        properties: [PropertyExtractor.PropertyInfo],
        access: String,
        isImmutable: Bool,
        conformances: DTOConformances
    ) -> String {
        let keyword = isImmutable ? "let" : "var"

        let propertyLines = properties.map { name, baseType, isOpt, isArr, isRelationship in
            let type = if isRelationship {
                isArr ? "[\(baseType)DTO]" : "\(baseType)DTO"
            } else {
                isArr ? "[\(baseType)]" : baseType
            }
            // Make all relationship properties optional, keep original optionality for non-relationships
            let optionalMark = isRelationship ? "?" : (isOpt ? "?" : "")
            return "\(access) \(keyword) \(name): \(type)\(optionalMark)"
        }.joined(separator: "\n")

        // Always start with CodableDTO
        var protocols = ["CodableDTO"]

        // Add selected conformances
        if conformances.contains(.equatable) {
            protocols.append("Equatable")
        }
        if conformances.contains(.hashable) {
            protocols.append("Hashable")
        }
        if conformances.contains(.sendable) {
            protocols.append("Sendable")
        }

        let protocolList = protocols.joined(separator: ", ")

        return if propertyLines.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            """
            \(access) struct \(name): \(protocolList) {}
            """
        } else {
            """
            \(access) struct \(name): \(protocolList) {
            \(propertyLines)
            }
            """
        }
    }

    static func buildToDTOMethod(
        properties: [PropertyExtractor.PropertyInfo],
        dtoName: String,
        access: String
    ) -> String {
        if properties.isEmpty {
            return "\(access) func toDTO() -> \(dtoName) { .init() }"
        }

        let initArgs = properties.map { name, _, isOpt, isArr, isRelationship in
            if isRelationship {
                if isArr {
                    // Check if the relationship value exists before mapping
                    """
                    \(name): $\(name).value != nil ? \(name).map { $0.toDTO() } : []
                    """
                } else {
                    // Check if the relationship value exists before converting
                    """
                    \(name): $\(name).value != nil ? \(name)\(isOpt ? "?" : "").toDTO() : nil
                    """
                }
            } else {
                "\(name): \(name)"
            }
        }.joined(separator: ",\n")

        return """
        \(access) func toDTO() -> \(dtoName) {
            .init(
                \(initArgs)
            )
        }
        """
    }
}
