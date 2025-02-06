# FluentDTO Examples & Patterns

This guide provides comprehensive examples of how to use the `@FluentDTO` macro effectively, along with common pitfalls to avoid.

## 📋 Table of Contents

- [Common Pitfalls](#-common-pitfalls)
- [Recommended Patterns](#-recommended-patterns)
- [Advanced Scenarios](#-advanced-scenarios)

## 🚫 Common Pitfalls

### 1. Infinite Size Cycles
The most common issue occurs when creating bidirectional relationships with optional properties:

```swift
// ❌ DON'T: Creates infinite size error
@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Author: Model {
    @ID var id: UUID?
    @OptionalChild(for: \.$author) var book: Book?  // Single optional relationship
    init() {}
}

@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Book: Model {
    @ID var id: UUID?
    @Parent(key: "author_id") var author: Author    // Creates cycle
    init() {}
}

// Generated structs would try to include each other infinitely:
// struct AuthorDTO: CodableDTO, Equatable, Sendable {
//     let id: UUID?
//     let book: BookDTO?  // Contains AuthorDTO which contains BookDTO...
// }

// ✅ DO: Use array relationships instead
@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Author: Model {
    @ID var id: UUID?
    @Children(for: \.$author) var books: [Book]     // Array breaks the cycle
    init() {}
}

// Generated struct is clean:
// struct AuthorDTO: CodableDTO, Equatable, Sendable {
//     let id: UUID?
//     let books: [BookDTO]
// }

### 2. Complex Relationship Cycles
Multi-model cycles can create subtle issues:

```swift
// ❌ DON'T: Three-way cycle with optional relationships
@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Student: Model {
    @OptionalParent(key: "advisor_id") var advisor: Professor?
    @OptionalChild(for: \.$student) var thesis: Thesis?
}

@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Professor: Model {
    @Children(for: \.$advisor) var students: [Student]
    @OptionalChild(for: \.$reviewer) var reviewingThesis: Thesis?
}

@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Thesis: Model {
    @Parent(key: "student_id") var student: Student
    @OptionalParent(key: "reviewer_id") var reviewer: Professor?
}

// ✅ DO: Break the cycle by choosing a primary direction
@FluentDTO(includeRelations: .children)
final class Professor: Model {
    @Children(for: \.$advisor) var students: [Student]
}

@FluentDTO(includeRelations: .parent)
final class Student: Model {
    @Parent(key: "advisor_id") var advisor: Professor
    @Children(for: \.$student) var theses: [Thesis]  // Use array
}

// Generated structs are cycle-free:
// struct ProfessorDTO: CodableDTO, Equatable, Sendable {
//     let students: [StudentDTO]
// }
// struct StudentDTO: CodableDTO, Equatable, Sendable {
//     let advisor: ProfessorDTO
//     let theses: [ThesisDTO]
// }
```

### 3. Self-referential Structures
Self-referential models require special attention:

```swift
// ❌ DON'T: Bidirectional self-reference with .all
@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Employee: Model {
    @OptionalParent(key: "manager_id") var manager: Employee?
    @Children(for: \.$manager) var subordinates: [Employee]
}

// ✅ DO: Use selective inclusion or arrays
@FluentDTO(includeRelations: .children)  // Only include child relationships
final class Employee: Model {
    @OptionalParent(key: "manager_id") var manager: Employee?
    @Children(for: \.$manager) var subordinates: [Employee]
}

// Generated struct is clean:
// struct EmployeeDTO: CodableDTO, Equatable, Sendable {
//     let subordinates: [EmployeeDTO]
// }
```

## ✅ Recommended Patterns

### 1. Array-Based Relationships
Array relationships provide the most reliable behavior:

```swift
@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Department: Model {
    @ID var id: UUID?
    @Children(for: \.$department) var employees: [Employee]
    @Children(for: \.$department) var projects: [Project]
}

@FluentDTO(includeRelations: .parent)
final class Employee: Model {
    @ID var id: UUID?
    @Parent(key: "department_id") var department: Department
    @Siblings(through: ProjectAssignment.self, from: \.$employee, to: \.$project) var projects: [Project]
}

// Generated structs:
// struct DepartmentDTO: CodableDTO, Equatable, Sendable {
//     let id: UUID?
//     let employees: [EmployeeDTO]
//     let projects: [ProjectDTO]
// }
```

### 2. Many-to-Many Relationships
Siblings relationships work exceptionally well:

```swift
@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Book: Model {
    @ID var id: UUID?
    @Siblings(through: BookTag.self, from: \.$book, to: \.$tag) var tags: [Tag]
}

@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Tag: Model {
    @ID var id: UUID?
    @Siblings(through: BookTag.self, from: \.$tag, to: \.$book) var books: [Book]
}

// Generated structs:
// struct BookDTO: CodableDTO, Equatable, Sendable {
//     let id: UUID?
//     let tags: [TagDTO]
// }
// struct TagDTO: CodableDTO, Equatable, Sendable {
//     let id: UUID?
//     let books: [BookDTO]
// }
```

## 🔄 Advanced Scenarios

### 1. Deep Hierarchies
Managing multi-level relationships:

```swift
@FluentDTO(includeRelations: .children)
final class Organization: Model {
    @Children(for: \.$organization) var departments: [Department]
}

@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Department: Model {
    @Parent(key: "org_id") var organization: Organization
    @Children(for: \.$department) var teams: [Team]
}

@FluentDTO(includeRelations: .all)  // Same as [.parent, .children]
final class Team: Model {
    @Parent(key: "department_id") var department: Department
    @Children(for: \.$team) var members: [Employee]
}

@FluentDTO(includeRelations: .parent)
final class Employee: Model {
    @Parent(key: "team_id") var team: Team
}

// Generated structs maintain hierarchy:
// struct OrganizationDTO: CodableDTO, Equatable, Sendable {
//     let departments: [DepartmentDTO]
// }
// struct DepartmentDTO: CodableDTO, Equatable, Sendable {
//     let organization: OrganizationDTO
//     let teams: [TeamDTO]
// }
```