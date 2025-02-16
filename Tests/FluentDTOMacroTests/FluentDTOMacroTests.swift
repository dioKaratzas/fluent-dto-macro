#if canImport(Testing)
    import Testing
    import MacroTesting
    import FluentDTOMacro
    import FluentDTOMacroPlugin
    import FluentDTOMacroShared

    @Suite(
        .macros(
            macros: [
                "FluentDTO": FluentDTOMacro.self,
                "FluentDTOIgnore": FluentDTOIgnoreMacro.self
            ]
        )
    )
    struct FluentDTOMacroTests {
        // MARK: - 1️⃣ Basic Functionality Tests
        @Suite("Basic Functionality")
        struct BasicFunctionalityTests {
            @Test("Generates empty DTO struct for empty model")
            func generatesEmptyStruct() {
                assertMacro {
                    """
                    @FluentDTO
                    class EmptyModel {}
                    """
                } expansion: {
                    """
                    class EmptyModel {}

                    public struct EmptyModelDTO: CodableDTO, Equatable, Hashable, Sendable {
                    }

                    extension EmptyModel {
                        public func toDTO() -> EmptyModelDTO {
                            .init()
                        }
                    }
                    """
                }
            }

            @Test("Generates struct with basic fields")
            func generatesStructWithBasicFields() {
                assertMacro {
                    """
                    @FluentDTO
                    class Post {
                        var title: String
                        var body: String
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        var title: String
                        var body: String
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let title: String
                        public let body: String
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                title: title,
                                body: body
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles all primitive types correctly")
            func handlesPrimitiveTypes() {
                assertMacro {
                    """
                    @FluentDTO
                    class AllPrimitives {
                        var string: String
                        var int: Int
                        var double: Double
                        var float: Float
                        var bool: Bool
                        var date: Date
                        var uuid: UUID
                        var data: Data
                    }
                    """
                } expansion: {
                    """
                    class AllPrimitives {
                        var string: String
                        var int: Int
                        var double: Double
                        var float: Float
                        var bool: Bool
                        var date: Date
                        var uuid: UUID
                        var data: Data
                    }

                    public struct AllPrimitivesDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let string: String
                        public let int: Int
                        public let double: Double
                        public let float: Float
                        public let bool: Bool
                        public let date: Date
                        public let uuid: UUID
                        public let data: Data
                    }

                    extension AllPrimitives {
                        public func toDTO() -> AllPrimitivesDTO {
                            .init(
                                string: string,
                                int: int,
                                double: double,
                                float: float,
                                bool: bool,
                                date: date,
                                uuid: uuid,
                                data: data
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles mutable properties when immutable: false")
            func handlesMutableProperties() {
                assertMacro {
                    """
                    @FluentDTO(immutable: false)
                    class MutableModel {
                        var name: String
                        var age: Int
                    }
                    """
                } expansion: {
                    """
                    class MutableModel {
                        var name: String
                        var age: Int
                    }

                    public struct MutableModelDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public var name: String
                        public var age: Int
                    }

                    extension MutableModel {
                        public func toDTO() -> MutableModelDTO {
                            .init(
                                name: name,
                                age: age
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles optional and array types correctly")
            func handlesOptionalAndArrayTypes() {
                assertMacro {
                    """
                    @FluentDTO
                    class User {
                        var name: String?
                        var tags: [String]
                        var scores: [Int]?
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String?
                        var tags: [String]
                        var scores: [Int]?
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let name: String?
                        public let tags: [String]
                        public let scores: [Int]?
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name,
                                tags: tags,
                                scores: scores
                            )
                        }
                    }
                    """
                }
            }
        }

        // MARK: - 2️⃣ Relationship Tests
        @Suite("Relationship Handling")
        struct RelationshipTests {
            @Test("Includes only parent relationships with dot notation")
            func includesOnlyParentRelationshipsWithDot() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .parent)
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let author: UserDTO?
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                author: $author.value != nil ? author.toDTO() : nil
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes only parent relationships with fully qualified type")
            func includesOnlyParentRelationshipsWithFullType() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: IncludeRelations.parent)
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let author: UserDTO?
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                author: $author.value != nil ? author.toDTO() : nil
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes only children relationships")
            func includesOnlyChildrenRelationships() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .children)
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let comments: [CommentDTO]?
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                comments: $comments.value != nil ? comments.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes both parent and children relationships with array syntax")
            func includesBothRelationshipsWithArray() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: [.parent, .children])
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let author: UserDTO?
                        public let comments: [CommentDTO]?
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                author: $author.value != nil ? author.toDTO() : nil,
                                comments: $comments.value != nil ? comments.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes both parent and children relationships with .all")
            func includesBothRelationshipsWithAll() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .all)
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let author: UserDTO?
                        public let comments: [CommentDTO]?
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                author: $author.value != nil ? author.toDTO() : nil,
                                comments: $comments.value != nil ? comments.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes no relationships with .none")
            func includesNoRelationshipsWithNone() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .none)
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                        var title: String
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                        var title: String
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let title: String
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                title: title
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles optional relationships correctly")
            func handlesOptionalRelationships() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .parent)
                    class Comment {
                        @OptionalParent(key: "post_id") var post: Post?
                    }
                    """
                } expansion: {
                    """
                    class Comment {
                        @OptionalParent(key: "post_id") var post: Post?
                    }

                    public struct CommentDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let post: PostDTO?
                    }

                    extension Comment {
                        public func toDTO() -> CommentDTO {
                            .init(
                                post: $post.value != nil ? post?.toDTO() : nil
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles siblings relationships")
            func handlesSiblingsRelationships() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .children)
                    class User {
                        @Siblings(through: UserRole.self, from: \\.$user, to: \\.$role)
                        var roles: [Role]
                    }
                    """
                } expansion: {
                    """
                    class User {
                        @Siblings(through: UserRole.self, from: \\.$user, to: \\.$role)
                        var roles: [Role]
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let roles: [RoleDTO]?
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                roles: $roles.value != nil ? roles.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes non-relationship properties with custom wrappers")
            func includesNonRelationshipProperties() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .parent)
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                        @CustomWrapper var title: String
                        @Timestamp var createdAt: Date
                        var normalProperty: String
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        @Parent(key: "author_id") var author: User
                        @Children(for: \\.$post) var comments: [Comment]
                        @CustomWrapper var title: String
                        @Timestamp var createdAt: Date
                        var normalProperty: String
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let author: UserDTO?
                        public let title: String
                        public let createdAt: Date
                        public let normalProperty: String
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                author: $author.value != nil ? author.toDTO() : nil,
                                title: title,
                                createdAt: createdAt,
                                normalProperty: normalProperty
                            )
                        }
                    }
                    """
                }
            }
        }

        // MARK: - 3️⃣ Access Level Tests
        @Suite("Access Level")
        struct AccessLevelTests {
            @Test("Matches model's access level")
            func matchesModelAccessLevel() {
                assertMacro {
                    """
                    @FluentDTO(accessLevel: .matchModel)
                    public class Post {
                        var title: String
                    }
                    """
                } expansion: {
                    """
                    public class Post {
                        var title: String
                    }

                    public struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let title: String
                    }

                    extension Post {
                        public func toDTO() -> PostDTO {
                            .init(
                                title: title
                            )
                        }
                    }
                    """
                }
            }

            @Test("Uses custom access level")
            func usesCustomAccessLevel() {
                assertMacro {
                    """
                    @FluentDTO(accessLevel: .internal)
                    public class Post {
                        var title: String
                    }
                    """
                } expansion: {
                    """
                    public class Post {
                        var title: String
                    }

                    internal struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        internal let title: String
                    }

                    extension Post {
                        internal func toDTO() -> PostDTO {
                            .init(
                                title: title
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles fileprivate access")
            func handlesFileprivateAccess() {
                assertMacro {
                    """
                    @FluentDTO(accessLevel: .fileprivate)
                    class Post {
                        var title: String
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        var title: String
                    }

                    fileprivate struct PostDTO: CodableDTO, Equatable, Hashable, Sendable {
                        fileprivate let title: String
                    }

                    extension Post {
                        fileprivate func toDTO() -> PostDTO {
                            .init(
                                title: title
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles open class correctly")
            func handlesOpenClass() {
                assertMacro {
                    """
                    @FluentDTO(accessLevel: .matchModel)
                    open class BaseModel {
                        var id: UUID?
                    }
                    """
                } expansion: {
                    """
                    open class BaseModel {
                        var id: UUID?
                    }

                    public struct BaseModelDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let id: UUID?
                    }

                    extension BaseModel {
                        public func toDTO() -> BaseModelDTO {
                            .init(
                                id: id
                            )
                        }
                    }
                    """
                }
            }
        }

        // MARK: - 4️⃣ Ignore Attribute Tests
        @Suite("Ignore Attribute")
        struct IgnoreAttributeTests {
            @Test("Ignores fields marked with @FluentDTOIgnore")
            func ignoresMarkedFields() {
                assertMacro {
                    """
                    @FluentDTO
                    class User {
                        var username: String
                        @FluentDTOIgnore
                        var password: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var username: String
                        var password: String
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let username: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                username: username
                            )
                        }
                    }
                    """
                }
            }

            @Test("Ignores multiple fields with mixed attributes")
            func ignoresMultipleFieldsWithMixedAttributes() {
                assertMacro {
                    """
                    @FluentDTO
                    class User {
                        @ID(key: .id)
                        var id: UUID?

                        @Field(key: "username")
                        var username: String

                        @FluentDTOIgnore
                        @Field(key: "password_hash")
                        var passwordHash: String

                        @FluentDTOIgnore
                        @Field(key: "secret_key")
                        var secretKey: String

                        @Children(for: \\.$user)
                        var posts: [Post]
                    }
                    """
                } expansion: {
                    """
                    class User {
                        @ID(key: .id)
                        var id: UUID?

                        @Field(key: "username")
                        var username: String
                        @Field(key: "password_hash")
                        var passwordHash: String
                        @Field(key: "secret_key")
                        var secretKey: String

                        @Children(for: \\.$user)
                        var posts: [Post]
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let id: UUID?
                        public let username: String
                        public let posts: [PostDTO]?
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                id: id,
                                username: username,
                                posts: $posts.value != nil ? posts.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }
        }

        // MARK: - 5️⃣ Edge Cases & Error Handling
        @Suite("Edge Cases")
        struct EdgeCaseTests {
            @Test("Handles empty struct with relationships")
            func handlesEmptyStructWithRelationships() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .children)
                    class EmptyWithRelations {
                        @Children(for: \\.$parent) var children: [Child]
                    }
                    """
                } expansion: {
                    """
                    class EmptyWithRelations {
                        @Children(for: \\.$parent) var children: [Child]
                    }

                    public struct EmptyWithRelationsDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let children: [ChildDTO]?
                    }

                    extension EmptyWithRelations {
                        public func toDTO() -> EmptyWithRelationsDTO {
                            .init(
                                children: $children.value != nil ? children.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles complex nested types")
            func handlesComplexNestedTypes() {
                assertMacro {
                    """
                    @FluentDTO
                    class ComplexModel {
                        var simpleDict: [String: Int]
                        var optArrayDict: [String: [Int]]?
                        var arrayOptDict: [[String: Int?]]
                    }
                    """
                } expansion: {
                    """
                    class ComplexModel {
                        var simpleDict: [String: Int]
                        var optArrayDict: [String: [Int]]?
                        var arrayOptDict: [[String: Int?]]
                    }

                    public struct ComplexModelDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let simpleDict: [String: Int]
                        public let optArrayDict: [String: [Int]]?
                        public let arrayOptDict: [[String: Int?]]
                    }

                    extension ComplexModel {
                        public func toDTO() -> ComplexModelDTO {
                            .init(
                                simpleDict: simpleDict,
                                optArrayDict: optArrayDict,
                                arrayOptDict: arrayOptDict
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles nested optionals correctly")
            func handlesNestedOptionals() {
                assertMacro {
                    """
                    @FluentDTO
                    class NestedOptionals {
                        var maybeArray: [String?]?
                        var arrayOfOptionals: [String?]
                        var optionalArray: [String]?
                    }
                    """
                } expansion: {
                    """
                    class NestedOptionals {
                        var maybeArray: [String?]?
                        var arrayOfOptionals: [String?]
                        var optionalArray: [String]?
                    }

                    public struct NestedOptionalsDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let maybeArray: [String?]?
                        public let arrayOfOptionals: [String?]
                        public let optionalArray: [String]?
                    }

                    extension NestedOptionals {
                        public func toDTO() -> NestedOptionalsDTO {
                            .init(
                                maybeArray: maybeArray,
                                arrayOfOptionals: arrayOfOptionals,
                                optionalArray: optionalArray
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles all Fluent field wrappers")
            func handlesAllFluentFieldWrappers() {
                assertMacro {
                    """
                    @FluentDTO
                    final class AllWrappers: Model {
                        @ID(key: .id)
                        var id: UUID?

                        @Field(key: "name")
                        var name: String

                        @Enum(key: "status")
                        var status: Status

                        @Group(key: "metadata")
                        var metadata: Metadata

                        @Timestamp(key: "created_at", on: .create)
                        var createdAt: Date?

                        @CompositeID
                        var compositeId: CompositeID
                    }
                    """
                } expansion: {
                    """
                    final class AllWrappers: Model {
                        @ID(key: .id)
                        var id: UUID?

                        @Field(key: "name")
                        var name: String

                        @Enum(key: "status")
                        var status: Status

                        @Group(key: "metadata")
                        var metadata: Metadata

                        @Timestamp(key: "created_at", on: .create)
                        var createdAt: Date?

                        @CompositeID
                        var compositeId: CompositeID
                    }

                    public struct AllWrappersDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let id: UUID?
                        public let name: String
                        public let status: Status
                        public let metadata: Metadata
                        public let createdAt: Date?
                        public let compositeId: CompositeID
                    }

                    extension AllWrappers {
                        public func toDTO() -> AllWrappersDTO {
                            .init(
                                id: id,
                                name: name,
                                status: status,
                                metadata: metadata,
                                createdAt: createdAt,
                                compositeId: compositeId
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles complex types with specific conformances")
            func complexTypesWithSpecificConformances() {
                assertMacro {
                    """
                    @FluentDTO(conformances: [.equatable, .hashable])
                    class User {
                        var name: String?
                        var age: Int
                        var tags: [String]
                        @Children(for: \\.$user) var posts: [Post]
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String?
                        var age: Int
                        var tags: [String]
                        @Children(for: \\.$user) var posts: [Post]
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable {
                        public let name: String?
                        public let age: Int
                        public let tags: [String]
                        public let posts: [PostDTO]?
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name,
                                age: age,
                                tags: tags,
                                posts: $posts.value != nil ? posts.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles multiple relationships with mixed types")
            func handlesMultipleRelationshipsWithMixedTypes() {
                assertMacro {
                    """
                    @FluentDTO(includeRelations: .all)
                    class User {
                        @ID(key: .id) var id: UUID?
                        @Field(key: "username") var username: String
                        @Parent(key: "team_id") var team: Team
                        @OptionalParent(key: "department_id") var department: Department?
                        @Children(for: \\.$user) var posts: [Post]
                        @Siblings(through: UserRole.self, from: \\.$user, to: \\.$role) var roles: [Role]
                    }
                    """
                } expansion: {
                    """
                    class User {
                        @ID(key: .id) var id: UUID?
                        @Field(key: "username") var username: String
                        @Parent(key: "team_id") var team: Team
                        @OptionalParent(key: "department_id") var department: Department?
                        @Children(for: \\.$user) var posts: [Post]
                        @Siblings(through: UserRole.self, from: \\.$user, to: \\.$role) var roles: [Role]
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let id: UUID?
                        public let username: String
                        public let team: TeamDTO?
                        public let department: DepartmentDTO?
                        public let posts: [PostDTO]?
                        public let roles: [RoleDTO]?
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                id: id,
                                username: username,
                                team: $team.value != nil ? team.toDTO() : nil,
                                department: $department.value != nil ? department?.toDTO() : nil,
                                posts: $posts.value != nil ? posts.map {
                                    $0.toDTO()
                                } : [],
                                roles: $roles.value != nil ? roles.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }
        }

        // MARK: - Protocol Conformance Tests
        @Suite("Protocol Conformances")
        struct ProtocolConformanceTests {
            @Test("Default conformances include all protocols")
            func defaultConformancesIncludeAll() {
                assertMacro {
                    """
                    @FluentDTO
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify only Equatable conformance")
            func onlyEquatableConformance() {
                assertMacro {
                    """
                    @FluentDTO(conformances: .equatable)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Equatable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify only Hashable conformance")
            func onlyHashableConformance() {
                assertMacro {
                    """
                    @FluentDTO(conformances: .hashable)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Hashable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify only Sendable conformance")
            func onlySendableConformance() {
                assertMacro {
                    """
                    @FluentDTO(conformances: .sendable)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify Equatable and Hashable conformance")
            func equatableAndHashableConformance() {
                assertMacro {
                    """
                    @FluentDTO(conformances: [.equatable, .hashable])
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify Equatable and Sendable conformance")
            func equatableAndSendableConformance() {
                assertMacro {
                    """
                    @FluentDTO(conformances: [.equatable, .sendable])
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Equatable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify Hashable and Sendable conformance")
            func hashableAndSendableConformance() {
                assertMacro {
                    """
                    @FluentDTO(conformances: [.hashable, .sendable])
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Hashable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify all conformances explicitly")
            func allConformancesExplicitly() {
                assertMacro {
                    """
                    @FluentDTO(conformances: [.equatable, .hashable, .sendable])
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify all conformances using .all")
            func allConformancesUsingAll() {
                assertMacro {
                    """
                    @FluentDTO(conformances: .all)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Can specify no additional conformances")
            func noAdditionalConformances() {
                assertMacro {
                    """
                    @FluentDTO(conformances: .none)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserDTO: CodableDTO {
                        public let name: String
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name
                            )
                        }
                    }
                    """
                }
            }

            @Test("Handles complex types with specific conformances")
            func complexTypesWithSpecificConformances() {
                assertMacro {
                    """
                    @FluentDTO(conformances: [.equatable, .hashable])
                    class User {
                        var name: String?
                        var age: Int
                        var tags: [String]
                        @Children(for: \\.$user) var posts: [Post]
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String?
                        var age: Int
                        var tags: [String]
                        @Children(for: \\.$user) var posts: [Post]
                    }

                    public struct UserDTO: CodableDTO, Equatable, Hashable {
                        public let name: String?
                        public let age: Int
                        public let tags: [String]
                        public let posts: [PostDTO]?
                    }

                    extension User {
                        public func toDTO() -> UserDTO {
                            .init(
                                name: name,
                                age: age,
                                tags: tags,
                                posts: $posts.value != nil ? posts.map {
                                    $0.toDTO()
                                } : []
                            )
                        }
                    }
                    """
                }
            }
        }
    }
#endif
