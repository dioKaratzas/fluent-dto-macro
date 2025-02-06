import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct FluentContentPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FluentContentMacro.self,
        FluentContentIgnoreMacro.self,
        FluentContentTypeAliasMacro.self
    ]
} 