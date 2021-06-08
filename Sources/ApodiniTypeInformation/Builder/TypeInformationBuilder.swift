//
//  File.swift
//  
//
//  Created by Eldi Cano on 05.06.21.
//

import Foundation

/// A builder protocol where `Result` is `TypeInformation`
public protocol TypeInformationBuilder: Builder where Input == Any.Type, Result == TypeInformation {}

// MARK: - TypeInformationBuilder
public extension TypeInformationBuilder {
    /// Builds a typeinformation instance with `Self`
    static func result(of input: Input) throws -> Result {
        try Self(input).build()
    }
}

// MARK: - TypeInformation
public extension TypeInformation {
    /// Returns a `TypeInformation` instance built with `builderType`
    static func of<B: TypeInformationBuilder>(_ type: Any.Type, with builderType: B.Type) throws -> TypeInformation {
        try builderType.init(type).build()
    }
}

protocol TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation
}

extension Optional: TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation {
        .optional(wrappedValue: try .of(Wrapped.self, with: T.self))
    }
}

extension Array: TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation {
        .repeated(element: try .of(Element.self, with: T.self))
    }
}

extension Set: TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation {
        .repeated(element: try .of(Element.self, with: T.self))
    }
}

extension Dictionary: TypeInformationComplexConstructor {
    static func construct<T: TypeInformationBuilder>(with builderType: T.Type) throws -> TypeInformation {
        guard let primitiveKey = PrimitiveType(Key.self) else {
            throw TypeInformation.TypeInformationError.notSupportedDictionaryKeyType
        }
        return .dictionary(key: primitiveKey, value: try .of(Value.self, with: T.self))
    }
}
