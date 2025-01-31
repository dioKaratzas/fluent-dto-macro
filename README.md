# FluentContent

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/Vapor-4.0-blue.svg)](https://vapor.codes)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A powerful Swift macro that revolutionizes how you handle Vapor Fluent models in your API responses. It automatically generates clean, type-safe Content DTOs, eliminating boilerplate while maintaining a clear separation between your database models and API layer.

## ✨ Highlights

- 🚀 **Zero Boilerplate** - Automatic DTO generation with a single macro
- 🔄 **Smart Relationships** - Intelligent handling of all Fluent relationship types
- 🛡️ **Type Safety** - Compile-time checking and immutable structures by default
- 🎯 **Flexible Control** - Fine-grained control over included relationships
- 🔒 **Security First** - Easy exclusion of sensitive fields
- 🎨 **Clean Architecture** - Perfect separation of database and API concerns

## 📦 Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/karadzic/fluent-content-macro.git", from: "1.0.0")
]

targets: [
    .target(name: "YourTarget",
            dependencies: [
                .product(name: "FluentContentMacro", package: "fluent-content-macro")
            ])
]
```

## 🚀 Quick Start

1️⃣ Import the package:
```swift
import FluentContentMacro
```

2️⃣ Add the macro to your model:
```swift
@FluentContent
final class User: Model {
    @ID var id: UUID?
    @Field(key: "name") var name: String
    @Children(for: \.$user) var posts: [Post]
}
```

3️⃣ Use the generated content:
```swift
func getUser(_ req: Request) async throws -> UserContent {
    let user = try await User.find(req.parameters.get("id"), on: req.db)
    return user.toContent()  // Type-safe UserContent struct
}
```

## ⚙️ Configuration

### Relationship Control
Choose which relationships to include in your DTOs:
```swift
// Only include child relationships (default)
@FluentContent(includeRelations: .children)

// Only include parent relationships
@FluentContent(includeRelations: .parent)

// Include both parent and child relationships
@FluentContent(includeRelations: .both)
```

### Immutability
Control property mutability:
```swift
// Immutable properties with 'let' (default)
@FluentContent(immutable: true)

// Mutable properties with 'var'
@FluentContent(immutable: false)
```

### Access Control
Set visibility levels:
```swift
// Public access (default)
@FluentContent(accessLevel: .public)

// Other options
@FluentContent(accessLevel: .internal)
@FluentContent(accessLevel: .fileprivate)
@FluentContent(accessLevel: .private)
```

### Field Exclusion
Protect sensitive data:
```swift
final class User: Model {
    @Field(key: "email") var email: String
    
    @FluentContentIgnore  // Exclude from Content DTO
    @Field(key: "password_hash") var passwordHash: String
}
```

## 📚 Advanced Usage

For comprehensive examples covering:
- Relationship cycles and how to handle them
- Complex hierarchical structures
- Many-to-many relationships
- Self-referential models
- Common pitfalls and solutions

See our detailed [EXAMPLES.md](EXAMPLES.md) guide.

## 🎯 Best Practices

1. Prefer array relationships for better type safety
2. Use selective relationship inclusion to prevent cycles
3. Be mindful of bidirectional relationships
4. Consider relationship depth when using `.both`
5. Leverage Many-to-Many relationships for complex associations

## 🤝 Contributing

We welcome contributions! Whether it's:
- 🐛 Bug fixes
- ✨ New features
- 📚 Documentation improvements
- 🧪 Additional tests

Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ❤️ Support

If you find FluentContent helpful in your projects, please consider:
- Giving it a ⭐️ on GitHub
- Sharing it with others
- Contributing back to the project
