//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.06.21.
//

import Foundation

/// An object type descriptor with `Model: Encodable` and `Keys: CodingKey` generic constraints
public class ObjectTypeDescriptor<Model: Encodable, Key: CodingKey>: TypeDescriptor {
    var properties: [TypeProperty]
    
    /// Initializer of an `ObjectTypeDescriptor`
    public init() {
        precondition(type(Model.self, isAnyOf: .struct, .class), "\(Model.self) must be a 'struct' or 'class'")
        
        properties = []
    }
    
    /// Registers a property in `self`
    /// - Parameters:
    ///   - primitive: a primitive type
    ///   - constraint: property constraint, `.required, .optional` or `.repeated`
    ///   - key: the corresponding coding key for which the property is encoded
    /// - Returns: `self` after registering the property
    public func property(_ primitive: PrimitiveType, _ constraint: PropertyConstraint, forKey key: Key) -> Self {
        assert(key: key)
        properties.append(.init(name: key.stringValue, type: TypeInformation.scalar(primitive).with(constraint)))
        return self
    }
    
    /// Registers a property in `self`
    /// - Parameters:
    ///   - referencing: a `TypeDescriber` type that the type of the property corresponds to
    ///   - constraint: property constraint, `.required, .optional` or `.repeated`
    ///   - key: the corresponding coding key for which the property is encoded
    /// - Returns: `self` after registering the property
    public func property(_ referencing: TypeDescriber.Type, _ constraint: PropertyConstraint, forKey key: Key) -> Self {
        assert(key: key)
        let typeInformation = referencing.typeDescriptor.typeInformation().with(constraint)
        
        properties.append(TypeProperty(name: key.stringValue, type: typeInformation))
        return self
    }
    
    /// Registers a dictionary property in `self`
    /// - Parameters:
    ///   - keyType: primtive type of dictionary keys
    ///   - valueType: primtive type of dictionary values
    ///   - key: the corresponding coding key for which the property is encoded
    /// - Returns: `self` after registering the property
    public func dictionary(_ keyType: PrimitiveType, valueType: PrimitiveType, forKey key: Key) -> Self {
        assert(key: key)
        properties.append(.init(name: key.stringValue, type: .dictionary(key: keyType, value: .scalar(valueType))))
        return self
    }
    
    /// Registers a dictionary property in `self`
    /// - Parameters:
    ///   - keyType: primtive type of dictionary keys
    ///   - valueType: a `TypeDescriber` type that the type of the dictionary values corresponds to
    ///   - key: the corresponding coding key for which the property is encoded
    /// - Returns: `self` after registering the property
    public func dictionary(_ keyType: PrimitiveType, valueType referencing: TypeDescriber.Type, forKey key: Key) -> Self {
        assert(key: key)
        let typeInformation = referencing.typeDescriptor.typeInformation()
        properties.append(.init(name: key.stringValue, type: .dictionary(key: keyType, value: typeInformation)))
        return self
    }
    
    /// Asserts the uniqueness of the to be registered property
    /// - Parameters:
    ///   - key: the coding key of the property
    private func assert(key: Key) {
        precondition(!properties.map { $0.name }.contains(key.stringValue), "Property with key: \(key.stringValue) has been already registered")
    }
}

// MARK: - _TypeDescriptor
extension ObjectTypeDescriptor: _TypeDescriptor {
    /// The corresponding `typeInformation` instance of `self`
    var typeInformation: TypeInformation {
        .object(name: .init(Model.self), properties: properties)
    }
}
