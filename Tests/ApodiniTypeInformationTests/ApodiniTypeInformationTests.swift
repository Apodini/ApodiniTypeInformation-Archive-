import XCTest
@testable import ApodiniTypeInformation

final class ApodiniTypeInformationTests: XCTestCase {
    func testDefault() {
        let date = Date.default
        XCTAssertEqual(date, Date().noon)
        
        let array = [[URL]].default
        XCTAssert(array.first?.first == URL.default)
        
        let optional = Optional<Float>.default
        XCTAssertNotNil(optional)
        
        let dictionary = [Int: Bool].default
        XCTAssert(dictionary.first?.key == 0)
    }
    
    func testInstanceEncoder() throws {
        enum Direction: String, Codable {
            case left
            case right
        }
        
        struct Car: Codable {
            let plateNumber: Int
            let name: String
            let direction: Direction
        }
        
        struct Shop: Codable {
            let id: UUID
            let licence: UInt?
            let url: [Int: URL]
            let directions: [UUID: Car]
        }
        
        struct SomeStruct: Codable {
            let someDictionary: [URL: Shop]
        }
        
        struct User: Codable {
            let birthday: [Date]
            let url: [URL]
            let scores: [Set<Int>]
            let name: String?
            let nestedDirections: [Direction]
            let shops: [Shop]
            let someDictionary: [SomeStruct]
            let cars: [String: Car]
            let otherCars: [Car]
            let null: Null
        }
        
        let encodable: Encodable.Type = [Int: User].self
        
        let fromRuntime = try TypeInformation.of(encodable, with: RuntimeBuilder.self)
        let fromEncoder = try TypeInformation.of(encodable, with: EncoderBuilder.self)
        XCTAssertEqual(fromRuntime, fromEncoder)
    }
    
    func testCustomEncoding() throws {
        struct UserID: Codable {
            let id: UUID
        }
        
        enum Direction: String, Codable {
            case right
            case links
        }
        
        struct User: Codable {
            // MARK: Private Inner Types
            enum CodingKeys: String, CodingKey {
                case id = "identifier", direction, age = "user_age"
            }
            
            let id: UserID
            let direction: [Direction]
            let age: UInt?
            
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                try container.encode([2: id.id.uuidString], forKey: .id)
                try container.encode(direction, forKey: .direction)
                try container.encode(id, forKey: .age)
            }
        }
        
        let fromEncoder = try TypeInformation.of(User.self, with: EncoderBuilder.self)
        
        let expected: TypeInformation = .object(name: .init(User.self), properties: [
            .property("identifier", type: .dictionary(key: .int, value: .scalar(.string))),
            .property("direction", type: .repeated(element: .enum(name: .init(Direction.self), cases: [.case("right"), .case("links")]))),
            .property("user_age", type: .object(name: .init(UserID.self), properties: [.property("id", type: .scalar(.uuid))]))
        ])
        XCTAssertEqual(fromEncoder, expected)
    }
    
    func testUnkeyedContainer() throws {
        struct User: Codable {
            let id: String
        }
        struct Users: Codable {
            let users: [User]
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.unkeyedContainer()
                
                try users.forEach { try container.encode($0) }
            }
        }
        
        let typeInformation = try EncoderBuilder.result(of: Users.self)
        let expected: TypeInformation = .repeated(element: .object(name: .init(Users.self), properties: [.property("id", type: .scalar(.string))]))
        
        XCTAssertEqual(typeInformation, expected)
    }
    
    func testTypeDescriptor() {
        enum ProgrammingLanguage: Int, Codable, TypeDescriber {
            case swift = 1
            case java = 7
            case other = 8
            
            static var typeDescriptor: TypeDescriptor {
                Enum()
                    .case(.swift)
                    .case(.java)
                    .case(.other)
            }
        }
        
        struct GithubProfile: Codable, TypeDescriber {
            // MARK: Private Inner Types
            private enum CodingKeys: String, CodingKey {
                case url
            }
            
            let url: URL?
            
            static var typeDescriptor: TypeDescriptor {
                Object<CodingKeys>()
                    .property(.url, .optional, forKey: .url)
            }
        }
        

        struct User: Codable, TypeDescriber {
            // MARK: Private Inner Types
            private enum CodingKeys: String, CodingKey {
                case id = "identifier", githubProfile = "github", name, projects, programmingLanguage = "progLng"
            }
            
            let id: UUID?
            let githubProfile: GithubProfile
            let name: String
            let projects: [Date: String]
            let programmingLanguage: ProgrammingLanguage
            
            static var typeDescriptor: TypeDescriptor {
                Object<CodingKeys>()
                    .property(.uuid, .optional, forKey: .id)
                    .property(GithubProfile.self, .required, forKey: .githubProfile)
                    .property(.string, .required, forKey: .name)
                    .dictionary(.date, valueType: .string, forKey: .projects)
                    .property(ProgrammingLanguage.self, .required, forKey: .programmingLanguage)
            }
        }
        
        let usersTypeInformation = User.typeDescriptor.typeInformation()
        
        let expected: TypeInformation = .object(name: .init(User.self), properties: [
            .property("identifier", type: .optional(wrappedValue: .scalar(.uuid))),
            .property("github", type: .object(
                        name: .init(GithubProfile.self),
                        properties: [.init(name: "url", type: .optional(wrappedValue: .scalar(.url)))])
            ),
            .property("name", type: .scalar(.string)),
            .property("projects", type: .dictionary(key: .date, value: .scalar(.string))),
            .property("progLng", type: .enum(name: .init(ProgrammingLanguage.self), rawValueType: .int, cases: [
                .init("swift", rawValue: 1.json),
                .init("java", rawValue: 7.json),
                .init("other", rawValue: 8.json)
            ]))
        ])
        
        XCTAssertEqual(usersTypeInformation, expected)
    }
}
