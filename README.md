# FluentDTO

> **Note**: The package was renamed from FluentContentMacro to FluentDTOMacro shortly after initial release to better reflect its purpose. If you were one of the early adopters, please update your package references and macro usage accordingly.

[![Swift](https://img.shields.io/badge/Swift-5.9%20%7C%205.10%20%7C%206-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/Vapor-4.0-blue.svg)](https://vapor.codes)
[![Tests](https://github.com/dioKaratzas/fluent-dto-macro/actions/workflows/test.yml/badge.svg)](https://github.com/dioKaratzas/fluent-dto-macro/actions/workflows/test.yml)
[![Latest Release](https://img.shields.io/github/v/release/dioKaratzas/fluent-dto-macro)](https://github.com/dioKaratzas/fluent-dto-macro/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 📖 Overview

A Swift macro that simplifies how you handle Vapor Fluent models in your API responses. It automatically generates clean, type-safe DTOs, eliminating boilerplate while maintaining a clear separation between your database models and API layer.

## ✨ Features

- 🚀 **Reduced Boilerplate** - Automatic DTO generation with a simple macro
- 🔒 **Type Safety** - Compile-time validation of your model-to-DTO mappings
- 🎯 **Selective Fields** - Control which properties are exposed in your DTOs
- 🔄 **Relationship Support** - Automatically handles nested Fluent relationships
- 🧵 **Concurrency Ready** - Generated DTOs automatically conform to Sendable
- 🛠️ **Customizable** - Configure access levels, mutability, and protocol conformance
- 🔒 **Security First** - Easy exclusion of sensitive fields
- 🎨 **Clean Architecture** - Clear separation of database and API concerns

## 📦 Installation

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/diokaratzas/fluent-dto-macro.git", from: "1.0.0")
]
```

Then add the macro to your target's dependencies:

```swift
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "FluentDTOMacro", package: "fluent-dto-macro")
        ]
    )
]
```

## 🚀 Getting Started

1️⃣ Import the package:
```swift
import FluentDTOMacro
```

2️⃣ Add the macro to your model:
```swift
@FluentDTO
final class User: Model {
    @ID var id: UUID?
    @Field(key: "name") var name: String
    @Children(for: \.$user) var posts: [Post]
}

// The macro generates:
public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
    public let id: UUID?
    public let name: String
    public let posts: [PostDTO]
}

extension User {
    public func toDTO() -> UserDTO {
        .init(
            id: id,
            name: name,
            posts: posts.map { $0.toDTO() }
        )
    }
}
```

3️⃣ Use the generated DTO:
```swift
func getUser(_ req: Request) async throws -> UserDTO {
    let user = try await User.find(req.parameters.get("id"), on: req.db)
    return user.toDTO()  // Type-safe UserDTO struct
}
```

## ⚙️ Configuration

### Relationship Control
Choose which relationships to include in your DTOs:
```swift
// Only include child relationships (default)
@FluentDTO(includeRelations: .children)
final class Post: Model {
    @Children(for: \.$post) var comments: [Comment]
    @Parent(key: "author_id") var author: User  // Will be ignored
}

// Only include parent relationships
@FluentDTO(includeRelations: .parent)
final class Comment: Model {
    @Parent(key: "post_id") var post: Post
    @Children(for: \.$comment) var reactions: [Reaction]  // Will be ignored
}

// Include both parent and child relationships
@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Category: Model {
    @Parent(key: "parent_id") var parent: Category
    @Children(for: \.$parent) var subcategories: [Category]
}

// Include no relationships
@FluentDTO(includeRelations: .none)
final class Settings: Model {
    @Parent(key: "user_id") var user: User  // Will be ignored
    @Children(for: \.$settings) var logs: [Log]  // Will be ignored
}

// Mix and match relationships
@FluentDTO(includeRelations: [.parent, .children])  // Same as .all
final class CustomModel: Model {
    @Parent(key: "parent_id") var parent: Parent
    @Children(for: \.$parent) var children: [Child]
}
```

### Immutability
Control property mutability:
```swift
// Immutable properties with 'let' (default)
@FluentDTO(immutable: true)
final class Product: Model {
    @ID var id: UUID?
    @Field(key: "name") var name: String
    @Field(key: "price") var price: Double
}
// Generated with 'let' properties:
// struct ProductDTO: CodableDTO, Equatable, Sendable {
//     let id: UUID?
//     let name: String
//     let price: Double
// }

// Mutable properties with 'var'
@FluentDTO(immutable: false)
final class Cart: Model {
    @ID var id: UUID?
    @Field(key: "total") var total: Double
    @Parent(key: "user_id") var user: User
}
// Generated with 'var' properties:
// struct CartDTO: CodableDTO, Equatable, Sendable {
//     var id: UUID?
//     var total: Double
//     var user: UserDTO
// }
```

### Access Control
Set visibility levels:
```swift
// Public access (default)
@FluentDTO(accessLevel: .public)
final class Article: Model {
    @ID var id: UUID?
    @Field(key: "title") var title: String
}
// Generated with public access:
// public struct ArticleDTO: CodableDTO, Equatable, Sendable { ... }
// public func toDTO() -> ArticleDTO { ... }

// Internal access
@FluentDTO(accessLevel: .internal)
final class Draft: Model {
    @ID var id: UUID?
    @Field(key: "content") var content: String
}
// Generated with internal access:
// struct DraftDTO: CodableDTO, Equatable, Sendable { ... }
// func toDTO() -> DraftDTO { ... }

// FilePrivate access for internal caching
@FluentDTO(accessLevel: .fileprivate)
final class Cache: Model {
    @ID var id: UUID?
    @Field(key: "data") var data: Data
}
// Generated with fileprivate access:
// fileprivate struct CacheDTO: CodableDTO, Equatable, Sendable { ... }
// fileprivate func toDTO() -> CacheDTO { ... }

// Private access for implementation details
@FluentDTO(accessLevel: .private)
final class InternalLog: Model {
    @ID var id: UUID?
    @Field(key: "message") var message: String
}
// Generated with private access:
// private struct InternalLogDTO: CodableDTO, Equatable, Sendable { ... }
// private func toDTO() -> InternalLogDTO { ... }
```

### Field Exclusion
Protect sensitive data:
```swift
final class User: Model {
    @Field(key: "email") var email: String
    
    @FluentDTOIgnore  // Exclude from generated DTO
    @Field(key: "password_hash") var passwordHash: String
}
```

### Protocol Conformances
Control which protocols your DTOs conform to:
```swift
// All protocols (default)
@FluentDTO(conformances: .all)  // Equatable, Hashable, and Sendable

// Single protocol
@FluentDTO(conformances: .equatable)  // Only Equatable
@FluentDTO(conformances: .hashable)   // Only Hashable
@FluentDTO(conformances: .sendable)   // Only Sendable

// Multiple protocols
@FluentDTO(conformances: [.equatable, .hashable])     // Equatable and Hashable
@FluentDTO(conformances: [.equatable, .sendable])     // Equatable and Sendable
@FluentDTO(conformances: [.hashable, .sendable])      // Hashable and Sendable

// No additional protocols
@FluentDTO(conformances: .none)  // Only CodableDTO
```

### Global Defaults
Configure default behavior for all @FluentDTO usages in your app:
```swift
// In your app's setup code
FluentDTODefaults.immutable = false        // Make all DTOs mutable by default
FluentDTODefaults.includeRelations = .all  // Include all relationships by default
FluentDTODefaults.accessLevel = .internal  // Use internal access by default
FluentDTODefaults.conformances = [.equatable, .hashable]  // Default protocol conformances

// Individual @FluentDTO attributes still override the defaults
@FluentDTO(immutable: true)  // This specific type will be immutable
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

If you find FluentDTO helpful in your projects, please consider:
- Giving it a ⭐️ on GitHub
- Sharing it with others
- Contributing back to the project
