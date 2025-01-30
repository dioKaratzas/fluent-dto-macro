# FluentContent

A Swift macro that automatically generates content DTOs for your Fluent models, making it easy to separate your database models from your API responses.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/Vapor-4.0-blue.svg)](https://vapor.codes)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/yourusername/FluentContentMacro/blob/main/LICENSE)

## Features

- 🚀 **Zero Boilerplate**: Automatically generates content DTOs from your Fluent models
- 🔄 **Relationship Support**: Handles `@Parent`, `@Children`, and `@Siblings` relationships
- 🛡️ **Type Safety**: Full type safety and compile-time checking
- 🎯 **Selective Fields**: Easily exclude sensitive fields from your API responses
- 🔒 **Access Control**: Configurable access levels for generated content types
- 🎨 **Clean Architecture**: Helps maintain separation between database and API layers

## Installation

Add the dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/FluentContentMacro.git", from: "1.0.0")
]

targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "FluentContentMacro", package: "FluentContentMacro")
        ]
    )
]
```

## Usage

### Basic Usage

Simply add the `@FluentContent` macro to your Fluent model:

```swift
@FluentContent
final class Post: Model {
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "title")
    var title: String
    
    @Field(key: "content")
    var content: String
    
    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?
}
```

This generates a `PostContent` struct that you can use in your API responses:

```swift
// Generated automatically
public struct PostContent: Content, Equatable {
    public let id: UUID?
    public let title: String
    public let content: String
    public let createdAt: Date?
}
```

### Handling Relationships

The macro automatically handles Fluent relationships:

```swift
@FluentContent
final class User: Model {
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: "name")
    var name: String
    
    @Children(for: \.$posts)
    var posts: [Post]
    
    @Siblings(through: UserRole.self, from: \.$user, to: \.$role)
    var roles: [Role]
}
```

### Excluding Sensitive Fields

Use `@FluentContentIgnore` to exclude sensitive fields from the content DTO:

```swift
@FluentContent
final class User: Model {
    @Field(key: "email")
    var email: String
    
    @FluentContentIgnore
    @Field(key: "password_hash")
    var passwordHash: String
}
```

### Configuration Options

The macro supports several configuration options:

```swift
@FluentContent(
    immutable: false,              // Generate mutable properties
    includedWrappers: .parent,     // Include only parent relationships
    accessLevel: .internal         // Use internal access level
)
class MyModel: Model {
    // ...
}
```

#### Relationship Options

- `.parent`: Include only parent relationships (`@Parent`, `@OptionalParent`)
- `.children`: Include only child relationships (`@Children`, `@OptionalChild`, `@Siblings`)
- `.both`: Include both parent and child relationships

#### Access Level Options

- `.matchModel`: Match the model's access level
- `.public`
- `.internal`
- `.fileprivate`
- `.private`

### Handling Cyclic Relationships

When you have models that reference each other (e.g., `Post` has `author: User` and `User` has `posts: [Post]`), you might encounter a "Value type has infinite size" error. This happens because the compiler can't determine the final size of the generated content types.

There are several ways to handle this:

1. **Selective Relationship Direction** (Parent → Child or Child → Parent):
   ```swift
   // Option 1: Include only the Parent → Child direction
   @FluentContent(includedWrappers: .children)
   class User {
       @Children(for: \.$user) var posts: [Post]
   }

   @FluentContent
   class Post {
       @FluentContentIgnore
       @Parent(key: "user_id") var user: User
   }

   // Option 2: Include only the Child → Parent direction
   @FluentContent
   class User {
       @FluentContentIgnore
       @Children(for: \.$user) var posts: [Post]
   }

   @FluentContent(includedWrappers: .parent)
   class Post {
       @Parent(key: "user_id") var user: User
   }
   ```

2. **Using @FluentContentIgnore**:
   ```swift
   @FluentContent
   class Post {
       @Parent(key: "author_id") var author: User
       
       @FluentContentIgnore
       @Children(for: \.$post) var comments: [Comment]
   }
   ```

Choose the approach that best fits your API's needs. The key is to break the cycle by choosing one direction for the relationship in your content DTOs.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
