import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct FluentContentMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FluentContentMacro.self,
        FluentContentIgnoreMacro.self
    ]
}
