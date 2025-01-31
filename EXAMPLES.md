# FluentContent Examples & Patterns

This guide provides comprehensive examples of how to use the `@FluentContent` macro effectively, along with common pitfalls to avoid.

## 📋 Table of Contents

- [Common Pitfalls](#-common-pitfalls)
- [Recommended Patterns](#-recommended-patterns)
- [Advanced Scenarios](#-advanced-scenarios)

## 🚫 Common Pitfalls

### 1. Infinite Size Cycles
The most common issue occurs when creating bidirectional relationships with optional properties:

```swift
// ❌ DON'T: Creates infinite size error
@FluentContent(includeRelations: .both)
final class Author: Model {
    @ID var id: UUID?
    @OptionalChild(for: \.$author) var book: Book?  // Single optional relationship
    init() {}
}

@FluentContent(includeRelations: .both)
final class Book: Model {
    @ID var id: UUID?
    @Parent(key: "author_id") var author: Author    // Creates cycle
    init() {}
}

// ✅ DO: Use array relationships instead
@FluentContent(includeRelations: .both)
final class Author: Model {
    @ID var id: UUID?
    @Children(for: \.$author) var books: [Book]     // Array breaks the cycle
    init() {}
}
```

### 2. Complex Relationship Cycles
Multi-model cycles can create subtle issues:

```swift
// ❌ DON'T: Three-way cycle with optional relationships
@FluentContent(includeRelations: .both)
final class Student: Model {
    @OptionalParent(key: "advisor_id") var advisor: Professor?
    @OptionalChild(for: \.$student) var thesis: Thesis?
}

@FluentContent(includeRelations: .both)
final class Professor: Model {
    @Children(for: \.$advisor) var students: [Student]
    @OptionalChild(for: \.$reviewer) var reviewingThesis: Thesis?
}

@FluentContent(includeRelations: .both)
final class Thesis: Model {
    @Parent(key: "student_id") var student: Student
    @OptionalParent(key: "reviewer_id") var reviewer: Professor?
}

// ✅ DO: Break the cycle by choosing a primary direction
@FluentContent(includeRelations: .children)
final class Professor: Model {
    @Children(for: \.$advisor) var students: [Student]
}

@FluentContent(includeRelations: .parent)
final class Student: Model {
    @Parent(key: "advisor_id") var advisor: Professor
    @Children(for: \.$student) var theses: [Thesis]  // Use array
}
```

### 3. Self-referential Traps
Self-referential models require special attention:

```swift
// ❌ DON'T: Bidirectional self-reference with .both
@FluentContent(includeRelations: .both)
final class Employee: Model {
    @OptionalParent(key: "manager_id") var manager: Employee?
    @Children(for: \.$manager) var subordinates: [Employee]
}

// ✅ DO: Use selective inclusion or arrays
@FluentContent(includeRelations: .children)
final class Employee: Model {
    @OptionalParent(key: "manager_id") var manager: Employee?
    @Children(for: \.$manager) var subordinates: [Employee]
}
```

## ✅ Recommended Patterns

### 1. Array-Based Relationships
Array relationships provide the most reliable behavior:

```swift
@FluentContent(includeRelations: .both)
final class Department: Model {
    @ID var id: UUID?
    @Children(for: \.$department) var employees: [Employee]
    @Children(for: \.$department) var projects: [Project]
}

@FluentContent(includeRelations: .parent)
final class Employee: Model {
    @ID var id: UUID?
    @Parent(key: "department_id") var department: Department
    @Siblings(through: ProjectAssignment.self, from: \.$employee, to: \.$project) var projects: [Project]
}
```

### 2. Many-to-Many Relationships
Siblings relationships work exceptionally well:

```swift
@FluentContent(includeRelations: .both)
final class Book: Model {
    @ID var id: UUID?
    @Siblings(through: BookTag.self, from: \.$book, to: \.$tag) var tags: [Tag]
}

@FluentContent(includeRelations: .both)
final class Tag: Model {
    @ID var id: UUID?
    @Siblings(through: BookTag.self, from: \.$tag, to: \.$book) var books: [Book]
}
```

## 🔄 Advanced Scenarios

### 1. Deep Hierarchies
Managing multi-level relationships:

```swift
@FluentContent(includeRelations: .children)
final class Organization: Model {
    @Children(for: \.$organization) var departments: [Department]
}

@FluentContent(includeRelations: .both)
final class Department: Model {
    @Parent(key: "org_id") var organization: Organization
    @Children(for: \.$department) var teams: [Team]
}

@FluentContent(includeRelations: .both)
final class Team: Model {
    @Parent(key: "department_id") var department: Department
    @Children(for: \.$team) var members: [Employee]
}

@FluentContent(includeRelations: .parent)
final class Employee: Model {
    @Parent(key: "team_id") var team: Team
}
```

### 2. Complex Self-referential Structures
Safe handling of hierarchical self-references:

```swift
@FluentContent(includeRelations: .both)
final class Category: Model {
    @ID var id: UUID?
    @OptionalParent(key: "parent_id") var parent: Category?
    @Children(for: \.$parent) var subcategories: [Category]
    @Siblings(through: ProductCategory.self, from: \.$category, to: \.$product) var products: [Product]
}
```

## 🎯 Key Takeaways

1. **Array Relationships**
   - Prefer `@Children` over `@OptionalChild`
   - Use `@Siblings` for many-to-many relationships
   - Arrays naturally break cycles

2. **Relationship Direction**
   - Choose a primary direction for relationships
   - Use selective inclusion (`.parent`, `.children`) strategically
   - Avoid `.both` unless necessary

3. **Cycle Prevention**
   - Break cycles using array relationships
   - Use selective inclusion to prevent infinite size errors
   - Consider the entire relationship graph

4. **Self-referential Models**
   - Always use arrays for child relationships
   - Be cautious with bidirectional self-references
   - Consider using selective inclusion 