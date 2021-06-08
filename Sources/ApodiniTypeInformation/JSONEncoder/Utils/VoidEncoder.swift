//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.06.21.
//

import Foundation

enum RootContainerType {
    case keyedContainer
    case unkeyedContainer
    case singleValueContainer
}

class VoidEncoder: Encoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any]
    var requestedRootContainer: RootContainerType?
    
    init() {
        codingPath = []
        userInfo = [:]
    }
    
    func requestedContainer<E>(from value: E) -> RootContainerType where E: Encodable {
        try? value.encode(to: self)
        guard let requestedRootContainer = requestedRootContainer else {
            fatalError("Encodable value \(value) did not request any container")
        }
        
        return requestedRootContainer
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
        requestedRootContainer = .keyedContainer
        return KeyedEncodingContainer(VoidKeyedEncodingContainer<Key>())
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        requestedRootContainer = .unkeyedContainer
        return VoidUnkeyedEncodingContainer()
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        requestedRootContainer = .singleValueContainer
        return self
    }
}

extension VoidEncoder: SingleValueEncodingContainer {
    func encodeNil() throws {}
    func encode(_ value: Bool) throws {}
    func encode(_ value: String) throws {}
    func encode(_ value: Double) throws {}
    func encode(_ value: Float) throws {}
    func encode(_ value: Int) throws {}
    func encode(_ value: Int8) throws {}
    func encode(_ value: Int16) throws {}
    func encode(_ value: Int32) throws {}
    func encode(_ value: Int64) throws {}
    func encode(_ value: UInt) throws {}
    func encode(_ value: UInt8) throws {}
    func encode(_ value: UInt16) throws {}
    func encode(_ value: UInt32) throws {}
    func encode(_ value: UInt64) throws {}
    func encode<T>(_ value: T) throws where T: Encodable {}
}


struct VoidKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K
    var codingPath: [CodingKey]
    
    init() {
        codingPath = []
    }
    
    mutating func encodeNil(forKey key: Key) throws {}
    mutating func encode(_ value: Bool, forKey key: Key) throws {}
    mutating func encode(_ value: String, forKey key: Key) throws {}
    mutating func encode(_ value: Double, forKey key: Key) throws {}
    mutating func encode(_ value: Float, forKey key: Key) throws {}
    mutating func encode(_ value: Int, forKey key: Key) throws {}
    mutating func encode(_ value: Int8, forKey key: Key) throws {}
    mutating func encode(_ value: Int16, forKey key: Key) throws {}
    mutating func encode(_ value: Int32, forKey key: Key) throws {}
    mutating func encode(_ value: Int64, forKey key: Key) throws {}
    mutating func encode(_ value: UInt, forKey key: Key) throws {}
    mutating func encode(_ value: UInt8, forKey key: Key) throws {}
    mutating func encode(_ value: UInt16, forKey key: Key) throws {}
    mutating func encode(_ value: UInt32, forKey key: Key) throws {}
    mutating func encode(_ value: UInt64, forKey key: Key) throws {}
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T: Encodable {}
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        KeyedEncodingContainer(VoidKeyedEncodingContainer<NestedKey>())
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer { VoidUnkeyedEncodingContainer() }
    mutating func superEncoder() -> Encoder { VoidEncoder() }
    mutating func superEncoder(forKey key: Key) -> Encoder { VoidEncoder() }
}

struct VoidUnkeyedEncodingContainer: UnkeyedEncodingContainer {
    var codingPath: [CodingKey]
    var count: Int
    init() {
        codingPath = []
        count = 0
    }
    
    mutating func encodeNil() throws {}
    mutating func encode(_ value: Bool) throws {}
    mutating func encode(_ value: String) throws {}
    mutating func encode(_ value: Double) throws {}
    mutating func encode(_ value: Float) throws {}
    mutating func encode(_ value: Int) throws {}
    mutating func encode(_ value: Int8) throws {}
    mutating func encode(_ value: Int16) throws {}
    mutating func encode(_ value: Int32) throws {}
    mutating func encode(_ value: Int64) throws {}
    mutating func encode(_ value: UInt) throws {}
    mutating func encode(_ value: UInt8) throws {}
    mutating func encode(_ value: UInt16) throws {}
    mutating func encode(_ value: UInt32) throws {}
    mutating func encode(_ value: UInt64) throws {}
    mutating func encode<T>(_ value: T) throws where T: Encodable {}
    
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey: CodingKey {
        KeyedEncodingContainer(VoidKeyedEncodingContainer<NestedKey>())
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer { VoidUnkeyedEncodingContainer() }
    
    mutating func superEncoder() -> Encoder { VoidEncoder() }
}
