import SwiftSyntaxMacros
import SwiftCompilerPlugin

@main
struct FluentDTOMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FluentDTOMacro.self,
        FluentDTOIgnoreMacro.self
    ]
}
