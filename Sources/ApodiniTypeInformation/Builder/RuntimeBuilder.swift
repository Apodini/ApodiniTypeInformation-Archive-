//
//  File.swift
//  
//
//  Created by Eldi Cano on 05.06.21.
//

import Foundation

/// A struct to build `TypeInformation` instances out of `Any.Type`.
/// Uses the name of the variables of the type as property names of `.object` type information instances
public struct RuntimeBuilder: TypeInformationBuilder {
    /// Input of the builder
    public let input: Any.Type
    
    /// Initalizes `self` with `input`
    public init(_ input: Any.Type) {
        self.input = input
    }
    
    public func build() throws -> TypeInformation {
        if let primitiveType = PrimitiveType(input) {
            return .scalar(primitiveType)
        }
        
        let typeInfo = try info(of: input)
        
        if let primitive = try typeInfo.cardinality.primitive() {
            return primitive
        }
        
        return try .init(type: input)
    }
}
