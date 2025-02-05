import SwiftSyntax
import SwiftSyntaxBuilder
import FluentContentMacroShared

struct ContentStructBuilder {
    static func buildContentStruct(
        name: String,
        properties: [PropertyExtractor.PropertyInfo],
        access: String,
        isImmutable: Bool,
        conformances: ContentConformances
    ) -> String {
        let keyword = isImmutable ? "let" : "var"

        let propertyLines = properties.map { name, baseType, isOpt, isArr, isRelationship in
            let optionalMark = isOpt ? "?" : ""
            let type = if isRelationship {
                isArr ? "[\(baseType)Content]" : "\(baseType)Content"
            } else {
                isArr ? "[\(baseType)]" : baseType
            }
            return "\(access) \(keyword) \(name): \(type)\(optionalMark)"
        }.joined(separator: "\n")

        // Always start with CodableContent
        var protocols = ["CodableContent"]

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

    static func buildToContentMethod(
        properties: [PropertyExtractor.PropertyInfo],
        contentName: String,
        access: String
    ) -> String {
        if properties.isEmpty {
            return "\(access) func toContent() -> \(contentName) { .init() }"
        }

        let initArgs = properties.map { name, _, isOpt, isArr, isRelationship in
            if isRelationship {
                if isArr {
                    isOpt ? "\(name): \(name)?.map { $0.toContent() }" : "\(name): \(name).map { $0.toContent() }"
                } else {
                    isOpt ? "\(name): \(name)?.toContent()" : "\(name): \(name).toContent()"
                }
            } else {
                "\(name): \(name)"
            }
        }.joined(separator: ",\n")

        return """
        \(access) func toContent() -> \(contentName) {
            .init(
                \(initArgs)
            )
        }
        """
    }
}
