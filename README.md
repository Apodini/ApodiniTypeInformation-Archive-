# ApodiniTypeInformation

This package contains the implementation of a recurisive enum-based `TypeInformation`:
```swift
public enum TypeInformation: Value {
    /// A scalar type
    case scalar(PrimitiveType)
    /// A repeated type (set or array), with `TypeInformation` elements
    indirect case repeated(element: TypeInformation)
    /// A dictionary with primitive keys and `TypeInformation` values
    indirect case dictionary(key: PrimitiveType, value: TypeInformation)
    /// An optional type with `TypeInformation` wrapped values
    indirect case optional(wrappedValue: TypeInformation)
    /// An enum type with `String` cases
    case `enum`(name: TypeName, rawValueType: RawValueType, cases: [EnumCase])
    /// An object type with properties containing a `TypeInformation` and a name
    case object(name: TypeName, properties: [TypeProperty])
    /// A reference to a type information instance
    case reference(ReferenceKey)
}
```
The enum already conforms to `Codable` and `Hashable` and provides several other convenience methods that can be found in `TypeInformation+Convenience.swift`.
Currently, it supports the initalization out of a any type via `init(type:) throws` and out of any instance `init(value:) throws` using `Runtime` for the names
of the properties of the objects. Furthermore a `TypeInformation` instance can be initalized via `static func of<B: TypeInformationBuilder>(_ type: Any.Type, with builderType: B.Type) throws -> TypeInformation`
where the builder type can either be `RuntimeBuilder.self` or `EncoderBuilder.self`, e.g. `try TypeInformation.of(User.self, with: EncoderBuilder.self)`

`EncoderBuilder` uses an adjusted implementation of `Foundation.JSONEncoder` to additionally store type information while encoding a value. Before starting encoding,
`EncoderBuilder` makes use of a custom `InstanceCreator` object, to initialize an instance out of a type using `createInstance(of:) throws` of `Runtime`

When constructing the `TypeInformation` out of a type, the created instance recursively contains all the types of the properties. Additionally a
`TypesStore` can be used to reference a `TypeInformation` instance via `store(_ type: TypeInformation) -> TypeInformation`, which returns a `.reference` if the passed
type contains an `enum` or an `object`. The same instance can be reconstructed from the same `TypesStore` via `construct(from reference: TypeInformation) -> TypeInformation`

## Project structure

#### `Builder` directory

Contains `TypeInformationBuilder` protocol and concrete implementations of `EncoderBuilder` and `RuntimeBuilder`

#### `JSONEncoder` directory

Contains the adjusted `_JSONEncoder` implementation that stores type information of values at the path that it has been encoded. After encoding, the top-level `TypeInformation`
instance is constructed based on the paths of the collected type informations. The implementation of `_JSONEncoder` currently only considers `KeyedEncodingContainer`.

#### `Models` directory

Contains several models used throughout the package

#### `Shared` directory

Constains several extensions and util objects used throughout the package

#### `TypeDescriptor` directory

Contains the `TypeDescriber` protocol:
```swift
/// A protocol that requires introducing a `TypeDescriptor` static variable on a type
public protocol TypeDescriber: Encodable {
    /// A typealias for an `ObjectTypeDescriptor` where `Key` must conform to `CodingKey`
    typealias Object<Key> = ObjectTypeDescriptor<Self, Key> where Key: CodingKey
    /// A typealias for an `EnumTypeDescriptor` where Self must conform to `RawRepresentable` with an encodable rawValue type
    typealias Enum = EnumTypeDescriptor<Self> where Self: RawRepresentable, Self.RawValue: Encodable
    
    /// A static type descriptor variable that can be defined in either an `Object` or an `Enum`
    static var typeDescriptor: TypeDescriptor { get }
}
```

and two concrete implementations of `TypeDescriptor`, `ObjectTypeDescriptor` and `EnumTypeDescriptor`. Types conforming ty `TypeDescriber` must specify the structure of
their own type, e.g.

```swift
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
```

and that information can be used to construct a `TypeInformation` instance as specified by the user.

#### `TypeInformation` directory

Contains the of `TypeInformation` enum, its intialization via `Runtime` and the `TypesStore`

#### `ApodiniTypeInformationTests` directory

Contains a test case with some methods that showcase and test the functionalities mentioned above

