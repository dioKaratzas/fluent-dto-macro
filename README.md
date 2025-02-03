# FluentContent

[![Swift](https://img.shields.io/badge/Swift-5.10-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/Vapor-4.0-blue.svg)](https://vapor.codes)
[![Tests](https://github.com/dioKaratzas/fluent-content-macro/actions/workflows/test.yml/badge.svg)](https://github.com/dioKaratzas/fluent-content-macro/actions/workflows/test.yml)
[![Latest Release](https://img.shields.io/github/v/release/dioKaratzas/fluent-content-macro)](https://github.com/dioKaratzas/fluent-content-macro/releases/latest)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

A Swift macro that simplifies how you handle Vapor Fluent models in your API responses. It automatically generates clean, type-safe content structures, eliminating boilerplate while maintaining a clear separation between your database models and API layer.

## ✨ Highlights

- 🚀 **Reduced Boilerplate** - Automatic content structure generation with a simple macro
- 🔄 **Basic Relationships** - Support for common Fluent relationship types
- 🛡️ **Type Safety** - Compile-time checking and immutable structures by default
- 🎯 **Flexible Control** - Fine-grained control over included relationships
- 🔒 **Security First** - Easy exclusion of sensitive fields
- 🎨 **Clean Architecture** - Clear separation of database and API concerns

## 📦 Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/diokaratzas/fluent-content-macro.git", from: "1.0.0")
]

targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "FluentContentMacro", package: "fluent-content-macro")
        ]
    )
]
```

## 🚀 Getting Started

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

// The macro generates:
public struct UserContent: CodableContent, Equatable {
    public let id: UUID?
    public let name: String
    public let posts: [PostContent]
}

extension User {
    public func toContent() -> UserContent {
        .init(
            id: id,
            name: name,
            posts: posts.map { $0.toContent() }
        )
    }
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
Choose which relationships to include in your content structures:
```swift
// Only include child relationships (default)
@FluentContent(includeRelations: .children)
final class Post: Model {
    @Children(for: \.$post) var comments: [Comment]
    @Parent(key: "author_id") var author: User  // Will be ignored
}

// Only include parent relationships
@FluentContent(includeRelations: .parent)
final class Comment: Model {
    @Parent(key: "post_id") var post: Post
    @Children(for: \.$comment) var reactions: [Reaction]  // Will be ignored
}

// Include both parent and child relationships
@FluentContent(includeRelations: .both)
final class Category: Model {
    @Parent(key: "parent_id") var parent: Category
    @Children(for: \.$parent) var subcategories: [Category]
}
```

### Immutability
Control property mutability:
```swift
// Immutable properties with 'let' (default)
@FluentContent(immutable: true)
final class Product: Model {
    @ID var id: UUID?
    @Field(key: "name") var name: String
    @Field(key: "price") var price: Double
}
// Generated with 'let' properties:
// struct ProductContent {
//     let id: UUID?
//     let name: String
//     let price: Double
// }

// Mutable properties with 'var'
@FluentContent(immutable: false)
final class Cart: Model {
    @ID var id: UUID?
    @Field(key: "total") var total: Double
    @Parent(key: "user_id") var user: User
}
// Generated with 'var' properties:
// struct CartContent {
//     var id: UUID?
//     var total: Double
//     var user: UserContent
// }
```

### Access Control
Set visibility levels:
```swift
// Public access (default)
@FluentContent(accessLevel: .public)
final class Article: Model {
    @ID var id: UUID?
    @Field(key: "title") var title: String
}
// Generated with public access:
// public struct ArticleContent { ... }
// public func toContent() -> ArticleContent { ... }

// Internal access
@FluentContent(accessLevel: .internal)
final class Draft: Model {
    @ID var id: UUID?
    @Field(key: "content") var content: String
}
// Generated with internal access:
// struct DraftContent { ... }
// func toContent() -> DraftContent { ... }

// FilePrivate access for internal caching
@FluentContent(accessLevel: .fileprivate)
final class Cache: Model {
    @ID var id: UUID?
    @Field(key: "data") var data: Data
}
// Generated with fileprivate access:
// fileprivate struct CacheContent { ... }
// fileprivate func toContent() -> CacheContent { ... }

// Private access for implementation details
@FluentContent(accessLevel: .private)
final class InternalLog: Model {
    @ID var id: UUID?
    @Field(key: "message") var message: String
}
// Generated with private access:
// private struct InternalLogContent { ... }
// private func toContent() -> InternalLogContent { ... }
```

### Field Exclusion
Protect sensitive data:
```swift
final class User: Model {
    @Field(key: "email") var email: String
    
    @FluentContentIgnore  // Exclude from generated content structure
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