import SwiftSyntax
import SwiftSyntaxBuilder
import FluentContentMacroShared

struct ContentStructBuilder {
    static func buildContentStruct(
        name: String,
        properties: [PropertyExtractor.PropertyInfo],
        access: String,
        isImmutable: Bool
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

        return if propertyLines.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            """
            \(access) struct \(name): CodableContent, Equatable, Sendable {}
            """
        } else {
            """
            \(access) struct \(name): CodableContent, Equatable, Sendable {
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
