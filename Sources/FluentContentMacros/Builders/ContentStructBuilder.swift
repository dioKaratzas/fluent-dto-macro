import SwiftSyntax
import SwiftSyntaxBuilder
import FluentContentMacroShared

struct ContentStructBuilder {
    static func buildContentStruct(
        name: String,
        properties: [PropertyExtractor.PropertyInfo],
        access: String,
        isImmutable: Bool,
        conformances: ContentConformances,
        contentSuffix: String
    ) -> String {
        let keyword = isImmutable ? "let" : "var"

        let propertyLines = properties.map { name, baseType, isOpt, isArr, isRelationship in
            let optionalMark = isOpt ? "?" : ""
            let type = if isRelationship {
                isArr ? "[\(baseType)\(contentSuffix)]" : "\(baseType)\(contentSuffix)"
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

    static func buildConversionMethod(
        properties: [PropertyExtractor.PropertyInfo],
        contentName: String,
        methodName: String,
        access: String
    ) -> String {
        if properties.isEmpty {
            return "\(access) func \(methodName)() -> \(contentName) { .init() }"
        }

        let initArgs = properties.map { name, _, isOpt, isArr, isRelationship in
            if isRelationship {
                if isArr {
                    isOpt ? "\(name): \(name)?.map { $0.\(methodName)() }" : "\(name): \(name).map { $0.\(methodName)() }"
                } else {
                    isOpt ? "\(name): \(name)?.\(methodName)()" : "\(name): \(name).\(methodName)()"
                }
            } else {
                "\(name): \(name)"
            }
        }.joined(separator: ",\n")

        return """
        \(access) func \(methodName)() -> \(contentName) {
            .init(
                \(initArgs)
            )
        }
        """
    }
}
