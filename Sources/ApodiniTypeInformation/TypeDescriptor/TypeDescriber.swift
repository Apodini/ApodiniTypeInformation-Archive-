//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.06.21.
//

import Foundation

/// A protocol that requires introducing a `TypeDescriptor` static variable on a type
public protocol TypeDescriber: Encodable {
    /// A typealias for an `ObjectTypeDescriptor` where `Key` must conform to `CodingKey`
    typealias Object<Key> = ObjectTypeDescriptor<Self, Key> where Key: CodingKey
    /// A typealias for an `EnumTypeDescriptor` where Self must conform to `RawRepresentable` with an encodable rawValue type
    typealias Enum = EnumTypeDescriptor<Self> where Self: RawRepresentable, Self.RawValue: Encodable
    
    /// A static type descriptor variable that can be defined in either an `Object` or an `Enum`
    static var typeDescriptor: TypeDescriptor { get }
}
