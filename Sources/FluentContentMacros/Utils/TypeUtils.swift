import SwiftSyntax
import SwiftSyntaxBuilder

/// Utilities for working with Swift types in the macro system.
///
/// This enum provides helper methods for analyzing and manipulating Swift type syntax
/// within the macro system, particularly for handling optional and array types.
enum TypeUtils {
    /// Represents a type's base name and its modifiers (optional and array status)
    typealias TypeInfo = (baseType: String, isOptional: Bool, isArray: Bool)

    /// Unwraps optional and array type layers to get the base type and its modifiers.
    ///
    /// This method analyzes a type syntax node and determines:
    /// - The base type (e.g., "String" from "String?" or "[String]")
    /// - Whether the type is optional (has a ? suffix)
    /// - Whether the type is an array
    ///
    /// ## Examples
    /// ```swift
    /// String?     => ("String", true, false)
    /// [Int]       => ("Int", false, true)
    /// [User]?     => ("User", true, true)
    /// String      => ("String", false, false)
    /// ```
    ///
    /// - Parameter typeSyntax: The type syntax node to analyze
    /// - Returns: A TypeInfo containing the base type name and its modifiers
    static func unwrapTypeLayers(
        _ typeSyntax: TypeSyntax
    ) -> TypeInfo {
        var isOpt = false
        var isArr = false
        var current = typeSyntax

        while let optType = current.as(OptionalTypeSyntax.self) {
            isOpt = true
            current = optType.wrappedType
        }
        while let arrType = current.as(ArrayTypeSyntax.self) {
            isArr = true
            current = arrType.element
        }

        if let ident = current.as(IdentifierTypeSyntax.self) {
            return (ident.name.text, isOpt, isArr)
        }

        let text = current.description.trimmingCharacters(in: .whitespacesAndNewlines)
        return (text, isOpt, isArr)
    }
}
