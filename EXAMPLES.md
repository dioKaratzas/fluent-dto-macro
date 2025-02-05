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
@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Author: Model {
    @ID var id: UUID?
    @OptionalChild(for: \.$author) var book: Book?  // Single optional relationship
    init() {}
}

@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Book: Model {
    @ID var id: UUID?
    @Parent(key: "author_id") var author: Author    // Creates cycle
    init() {}
}

// Generated structs would try to include each other infinitely:
// struct AuthorContent: CodableContent, Equatable, Sendable {
//     let id: UUID?
//     let book: BookContent?  // Contains AuthorContent which contains BookContent...
// }

// ✅ DO: Use array relationships instead
@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Author: Model {
    @ID var id: UUID?
    @Children(for: \.$author) var books: [Book]     // Array breaks the cycle
    init() {}
}

// Generated struct is clean:
// struct AuthorContent: CodableContent, Equatable, Sendable {
//     let id: UUID?
//     let books: [BookContent]
// }

### 2. Complex Relationship Cycles
Multi-model cycles can create subtle issues:

```swift
// ❌ DON'T: Three-way cycle with optional relationships
@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Student: Model {
    @OptionalParent(key: "advisor_id") var advisor: Professor?
    @OptionalChild(for: \.$student) var thesis: Thesis?
}

@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Professor: Model {
    @Children(for: \.$advisor) var students: [Student]
    @OptionalChild(for: \.$reviewer) var reviewingThesis: Thesis?
}

@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
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

// Generated structs are cycle-free:
// struct ProfessorContent: CodableContent, Equatable, Sendable {
//     let students: [StudentContent]
// }
// struct StudentContent: CodableContent, Equatable, Sendable {
//     let advisor: ProfessorContent
//     let theses: [ThesisContent]
// }
```

### 3. Self-referential Structures
Self-referential models require special attention:

```swift
// ❌ DON'T: Bidirectional self-reference with .all
@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Employee: Model {
    @OptionalParent(key: "manager_id") var manager: Employee?
    @Children(for: \.$manager) var subordinates: [Employee]
}

// ✅ DO: Use selective inclusion or arrays
@FluentContent(includeRelations: .children)  // Only include child relationships
final class Employee: Model {
    @OptionalParent(key: "manager_id") var manager: Employee?
    @Children(for: \.$manager) var subordinates: [Employee]
}

// Generated struct is clean:
// struct EmployeeContent: CodableContent, Equatable, Sendable {
//     let subordinates: [EmployeeContent]
// }
```

## ✅ Recommended Patterns

### 1. Array-Based Relationships
Array relationships provide the most reliable behavior:

```swift
@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
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

// Generated structs:
// struct DepartmentContent: CodableContent, Equatable, Sendable {
//     let id: UUID?
//     let employees: [EmployeeContent]
//     let projects: [ProjectContent]
// }
```

### 2. Many-to-Many Relationships
Siblings relationships work exceptionally well:

```swift
@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Book: Model {
    @ID var id: UUID?
    @Siblings(through: BookTag.self, from: \.$book, to: \.$tag) var tags: [Tag]
}

@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Tag: Model {
    @ID var id: UUID?
    @Siblings(through: BookTag.self, from: \.$tag, to: \.$book) var books: [Book]
}

// Generated structs:
// struct BookContent: CodableContent, Equatable, Sendable {
//     let id: UUID?
//     let tags: [TagContent]
// }
// struct TagContent: CodableContent, Equatable, Sendable {
//     let id: UUID?
//     let books: [BookContent]
// }
```

## 🔄 Advanced Scenarios

### 1. Deep Hierarchies
Managing multi-level relationships:

```swift
@FluentContent(includeRelations: .children)
final class Organization: Model {
    @Children(for: \.$organization) var departments: [Department]
}

@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Department: Model {
    @Parent(key: "org_id") var organization: Organization
    @Children(for: \.$department) var teams: [Team]
}

@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Team: Model {
    @Parent(key: "department_id") var department: Department
    @Children(for: \.$team) var members: [Employee]
}

@FluentContent(includeRelations: .parent)
final class Employee: Model {
    @Parent(key: "team_id") var team: Team
}

// Generated structs maintain hierarchy:
// struct OrganizationContent: CodableContent, Equatable, Sendable {
//     let departments: [DepartmentContent]
// }
// struct DepartmentContent: CodableContent, Equatable, Sendable {
//     let organization: OrganizationContent
//     let teams: [TeamContent]
// }
```

### 2. Complex Self-referential Structures
Safe handling of hierarchical self-references:

```swift
@FluentContent(includeRelations: .all)  // Same as [.parent, .children]
final class Category: Model {
    @ID var id: UUID?
    @OptionalParent(key: "parent_id") var parent: Category?
    @Children(for: \.$parent) var subcategories: [Category]
    @Siblings(through: ProductCategory.self, from: \.$category, to: \.$product) var products: [Product]
}

// Generated struct handles self-reference:
// struct CategoryContent: CodableContent, Equatable, Sendable {
//     let id: UUID?
//     let parent: CategoryContent?
//     let subcategories: [CategoryContent]
//     let products: [ProductContent]
// }
```

## 🎯 Key Takeaways

1. **Array Relationships**
   - Prefer `@Children` over `@OptionalChild`
   - Use `@Siblings` for many-to-many relationships
   - Arrays naturally break cycles

2. **Relationship Direction**
   - Choose a primary direction for relationships
   - Use selective inclusion (`.parent`, `.children`) strategically
   - Avoid `.all` unless necessary

3. **Cycle Prevention**
   - Break cycles using array relationships
   - Use selective inclusion to prevent infinite size errors
   - Consider the entire relationship graph

4. **Self-referential Models**
   - Always use arrays for child relationships
   - Be cautious with bidirectional self-references
   - Consider using selective inclusion 