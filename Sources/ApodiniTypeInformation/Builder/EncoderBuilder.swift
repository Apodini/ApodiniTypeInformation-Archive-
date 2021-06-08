import Foundation

public struct EncoderBuilder: TypeInformationBuilder {
    public let input: Any.Type
    
    public init(_ input: Any.Type) {
        self.input = input
    }
    
    public func build() throws -> TypeInformation {
        if let primitiveType = PrimitiveType(input) {
            return .scalar(primitiveType)
        }
        
        let typeInfo = try info(of: input)
        let cardinality = typeInfo.cardinality
        
        if let primitive = try typeInfo.cardinality.primitive() {
            return primitive
        }
        
        let jsonEncoder = _JSONEncoder()
        
        let elementType = cardinality.nestedType
        
        let typeInstance = try instance(elementType)
        
        if let encodable = typeInstance as? Encodable {
            try encodable.encode(with: jsonEncoder, rootType: elementType)
        } else {
            fatalError("Failed to cast instance to encodable")
        }

        return try jsonEncoder.typeInformation().with(cardinality: cardinality)
    }
}

fileprivate extension TypeInformation {
    func with(cardinality: Cardinality) throws -> TypeInformation {
        switch cardinality {
        case .exactlyOne:
            return self
        case .repeated:
            return .repeated(element: self)
        case .optional:
            return .optional(wrappedValue: self)
        case let .dictionary(key, _):
            guard let primitiveKey = PrimitiveType(key) else {
                throw TypeInformationError.notSupportedDictionaryKeyType
            }
            return .dictionary(key: primitiveKey, value: self)
        }
    }
}

fileprivate extension Encodable {
    func encode(with jsonEncoder: _JSONEncoder, rootType: Any.Type) throws {
        jsonEncoder.rootType = rootType
        try encode(to: jsonEncoder)
    }
}
