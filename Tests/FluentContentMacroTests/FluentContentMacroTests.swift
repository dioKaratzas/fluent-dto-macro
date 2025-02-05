#if canImport(Testing)
    import Testing
    import MacroTesting
    import FluentContentMacro
    import FluentContentMacros
    import FluentContentMacroShared

    @Suite(
        .macros(
            macros: [
                "FluentContent": FluentContentMacro.self,
                "FluentContentIgnore": FluentContentIgnoreMacro.self
            ]
        )
    )
    struct FluentContentMacroTests {
        // MARK: - 1️⃣ Basic Functionality Tests
        @Suite("Basic Functionality")
        struct BasicFunctionalityTests {
            @Test("Generates empty content struct for empty model")
            func generatesEmptyStruct() {
                assertMacro {
                    """
                    @FluentContent
                    class EmptyModel {}
                    """
                } expansion: {
                    """
                    class EmptyModel {}

                    public struct EmptyModelContent: CodableContent, Equatable, Hashable, Sendable {
                    }

                    extension EmptyModel {
                        public func toContent() -> EmptyModelContent {
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
                    @FluentContent
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

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let title: String
                        public let body: String
                    }

                    extension Post {
                        public func toContent() -> PostContent {
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
                    @FluentContent
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

                    public struct AllPrimitivesContent: CodableContent, Equatable, Hashable, Sendable {
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
                        public func toContent() -> AllPrimitivesContent {
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
                    @FluentContent(immutable: false)
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

                    public struct MutableModelContent: CodableContent, Equatable, Hashable, Sendable {
                        public var name: String
                        public var age: Int
                    }

                    extension MutableModel {
                        public func toContent() -> MutableModelContent {
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
                    @FluentContent
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

                    public struct UserContent: CodableContent, Equatable, Hashable, Sendable {
                        public let name: String?
                        public let tags: [String]
                        public let scores: [Int]?
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(includeRelations: .parent)
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

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let author: UserContent
                    }

                    extension Post {
                        public func toContent() -> PostContent {
                            .init(
                                author: author.toContent()
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes only parent relationships with fully qualified enum")
            func includesOnlyParentRelationshipsWithFullEnum() {
                assertMacro {
                    """
                    @FluentContent(includeRelations: IncludeRelations.parent)
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

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let author: UserContent
                    }

                    extension Post {
                        public func toContent() -> PostContent {
                            .init(
                                author: author.toContent()
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes only child relationships with dot notation")
            func includesOnlyChildRelationshipsWithDot() {
                assertMacro {
                    """
                    @FluentContent(includeRelations: .children)
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

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let comments: [CommentContent]
                    }

                    extension Post {
                        public func toContent() -> PostContent {
                            .init(
                                comments: comments.map {
                                    $0.toContent()
                                }
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes only child relationships with fully qualified enum")
            func includesOnlyChildRelationshipsWithFullEnum() {
                assertMacro {
                    """
                    @FluentContent(includeRelations: IncludeRelations.children)
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

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let comments: [CommentContent]
                    }

                    extension Post {
                        public func toContent() -> PostContent {
                            .init(
                                comments: comments.map {
                                    $0.toContent()
                                }
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes both relationships with dot notation")
            func includesBothRelationshipsWithDot() {
                assertMacro {
                    """
                    @FluentContent(includeRelations: .both)
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

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let author: UserContent
                        public let comments: [CommentContent]
                    }

                    extension Post {
                        public func toContent() -> PostContent {
                            .init(
                                author: author.toContent(),
                                comments: comments.map {
                                    $0.toContent()
                                }
                            )
                        }
                    }
                    """
                }
            }

            @Test("Includes both relationships with fully qualified enum")
            func includesBothRelationshipsWithFullEnum() {
                assertMacro {
                    """
                    @FluentContent(includeRelations: IncludeRelations.both)
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

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let author: UserContent
                        public let comments: [CommentContent]
                    }

                    extension Post {
                        public func toContent() -> PostContent {
                            .init(
                                author: author.toContent(),
                                comments: comments.map {
                                    $0.toContent()
                                }
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
                    @FluentContent(includeRelations: .parent)
                    class Comment {
                        @OptionalParent(key: "post_id") var post: Post?
                    }
                    """
                } expansion: {
                    """
                    class Comment {
                        @OptionalParent(key: "post_id") var post: Post?
                    }

                    public struct CommentContent: CodableContent, Equatable, Hashable, Sendable {
                        public let post: PostContent?
                    }

                    extension Comment {
                        public func toContent() -> CommentContent {
                            .init(
                                post: post?.toContent()
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
                    @FluentContent(includeRelations: .children)
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

                    public struct UserContent: CodableContent, Equatable, Hashable, Sendable {
                        public let roles: [RoleContent]
                    }

                    extension User {
                        public func toContent() -> UserContent {
                            .init(
                                roles: roles.map {
                                    $0.toContent()
                                }
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
                    @FluentContent(includeRelations: .parent)
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

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let author: UserContent
                        public let title: String
                        public let createdAt: Date
                        public let normalProperty: String
                    }

                    extension Post {
                        public func toContent() -> PostContent {
                            .init(
                                author: author.toContent(),
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
                    @FluentContent(accessLevel: .matchModel)
                    public class Post {
                        var title: String
                    }
                    """
                } expansion: {
                    """
                    public class Post {
                        var title: String
                    }

                    public struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        public let title: String
                    }

                    extension Post {
                        public func toContent() -> PostContent {
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
                    @FluentContent(accessLevel: .internal)
                    public class Post {
                        var title: String
                    }
                    """
                } expansion: {
                    """
                    public class Post {
                        var title: String
                    }

                    internal struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        internal let title: String
                    }

                    extension Post {
                        internal func toContent() -> PostContent {
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
                    @FluentContent(accessLevel: .fileprivate)
                    class Post {
                        var title: String
                    }
                    """
                } expansion: {
                    """
                    class Post {
                        var title: String
                    }

                    fileprivate struct PostContent: CodableContent, Equatable, Hashable, Sendable {
                        fileprivate let title: String
                    }

                    extension Post {
                        fileprivate func toContent() -> PostContent {
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
                    @FluentContent(accessLevel: .matchModel)
                    open class BaseModel {
                        var id: UUID?
                    }
                    """
                } expansion: {
                    """
                    open class BaseModel {
                        var id: UUID?
                    }

                    public struct BaseModelContent: CodableContent, Equatable, Hashable, Sendable {
                        public let id: UUID?
                    }

                    extension BaseModel {
                        public func toContent() -> BaseModelContent {
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
            @Test("Ignores fields marked with @FluentContentIgnore")
            func ignoresMarkedFields() {
                assertMacro {
                    """
                    @FluentContent
                    class User {
                        var username: String
                        @FluentContentIgnore
                        var password: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var username: String
                        var password: String
                    }

                    public struct UserContent: CodableContent, Equatable, Hashable, Sendable {
                        public let username: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent
                    class User {
                        @ID(key: .id)
                        var id: UUID?

                        @Field(key: "username")
                        var username: String

                        @FluentContentIgnore
                        @Field(key: "password_hash")
                        var passwordHash: String

                        @FluentContentIgnore
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

                    public struct UserContent: CodableContent, Equatable, Hashable, Sendable {
                        public let id: UUID?
                        public let username: String
                        public let posts: [PostContent]
                    }

                    extension User {
                        public func toContent() -> UserContent {
                            .init(
                                id: id,
                                username: username,
                                posts: posts.map {
                                    $0.toContent()
                                }
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
                    @FluentContent(includeRelations: .children)
                    class EmptyWithRelations {
                        @Children(for: \\.$parent) var children: [Child]
                    }
                    """
                } expansion: {
                    """
                    class EmptyWithRelations {
                        @Children(for: \\.$parent) var children: [Child]
                    }

                    public struct EmptyWithRelationsContent: CodableContent, Equatable, Hashable, Sendable {
                        public let children: [ChildContent]
                    }

                    extension EmptyWithRelations {
                        public func toContent() -> EmptyWithRelationsContent {
                            .init(
                                children: children.map {
                                    $0.toContent()
                                }
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
                    @FluentContent
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

                    public struct ComplexModelContent: CodableContent, Equatable, Hashable, Sendable {
                        public let simpleDict: [String: Int]
                        public let optArrayDict: [String: [Int]]?
                        public let arrayOptDict: [[String: Int?]]
                    }

                    extension ComplexModel {
                        public func toContent() -> ComplexModelContent {
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
                    @FluentContent
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

                    public struct NestedOptionalsContent: CodableContent, Equatable, Hashable, Sendable {
                        public let maybeArray: [String?]?
                        public let arrayOfOptionals: [String?]
                        public let optionalArray: [String]?
                    }

                    extension NestedOptionals {
                        public func toContent() -> NestedOptionalsContent {
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
                    @FluentContent
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

                    public struct AllWrappersContent: CodableContent, Equatable, Hashable, Sendable {
                        public let id: UUID?
                        public let name: String
                        public let status: Status
                        public let metadata: Metadata
                        public let createdAt: Date?
                        public let compositeId: CompositeID
                    }

                    extension AllWrappers {
                        public func toContent() -> AllWrappersContent {
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
        }

        // MARK: - Protocol Conformance Tests
        @Suite("Protocol Conformances")
        struct ProtocolConformanceTests {
            @Test("Default conformances include all protocols")
            func defaultConformancesIncludeAll() {
                assertMacro {
                    """
                    @FluentContent
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Equatable, Hashable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: .equatable)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Equatable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: .hashable)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Hashable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: .sendable)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: [.equatable, .hashable])
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Equatable, Hashable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: [.equatable, .sendable])
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Equatable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: [.hashable, .sendable])
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Hashable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: [.equatable, .hashable, .sendable])
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Equatable, Hashable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: .all)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent, Equatable, Hashable, Sendable {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: .none)
                    class User {
                        var name: String
                    }
                    """
                } expansion: {
                    """
                    class User {
                        var name: String
                    }

                    public struct UserContent: CodableContent {
                        public let name: String
                    }

                    extension User {
                        public func toContent() -> UserContent {
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
                    @FluentContent(conformances: [.equatable, .hashable])
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

                    public struct UserContent: CodableContent, Equatable, Hashable {
                        public let name: String?
                        public let age: Int
                        public let tags: [String]
                        public let posts: [PostContent]
                    }

                    extension User {
                        public func toContent() -> UserContent {
                            .init(
                                name: name,
                                age: age,
                                tags: tags,
                                posts: posts.map {
                                    $0.toContent()
                                }
                            )
                        }
                    }
                    """
                }
            }
        }
    }
#endif
