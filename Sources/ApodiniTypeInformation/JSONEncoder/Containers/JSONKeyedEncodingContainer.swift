//
//  File.swift
//  
//
//  Created by Eldi Cano on 12.04.21.
//

import Foundation

// MARK: - Encoding Containers
struct JSONKeyedEncodingContainer<K: CodingKey>: KeyedEncodingContainerProtocol {
    typealias Key = K

    // MARK: Properties

    /// A reference to the encoder we're writing to.
    private let encoder: _JSONEncoder

    /// A reference to the container we're writing to.
    private let container: NSMutableDictionary

    /// The path of coding keys taken to get to this point in encoding.
    public private(set) var codingPath: [CodingKey]

    // MARK: - Initialization

    /// Initializes `self` with the given references.
    init(referencing encoder: _JSONEncoder, codingPath: [CodingKey], wrapping container: NSMutableDictionary) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    
    private func components(forKey key: Key) -> [String] {
        (codingPath.nonJSONKeys() + key).map { $0.stringValue }
    }
    
    // MARK: - KeyedEncodingContainerProtocol Methods

    public mutating func encodeNil(forKey key: Key) throws {
        encoder.store(.scalar(.null), at: components(forKey: key))
        self.container[key.stringValue] = NSNull()
    }
    
    public mutating func encode(_ value: Bool, forKey key: Key) throws {
        encoder.store(.scalar(.bool), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: Int, forKey key: Key) throws {
        encoder.store(.scalar(.int), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: Int8, forKey key: Key) throws {
        encoder.store(.scalar(.int8), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: Int16, forKey key: Key) throws {
        encoder.store(.scalar(.int16), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: Int32, forKey key: Key) throws {
        encoder.store(.scalar(.int32), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: Int64, forKey key: Key) throws {
        encoder.store(.scalar(.int64), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: UInt, forKey key: Key) throws {
        encoder.store(.scalar(.uint), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: UInt8, forKey key: Key) throws {
        encoder.store(.scalar(.uint8), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: UInt16, forKey key: Key) throws {
        encoder.store(.scalar(.uint16), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: UInt32, forKey key: Key) throws {
        encoder.store(.scalar(.uint32), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: UInt64, forKey key: Key) throws {
        encoder.store(.scalar(.uint64), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: String, forKey key: Key) throws {
        encoder.store(.scalar(.string), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }
    
    public mutating func encode(_ value: Float, forKey key: Key) throws {
        encoder.store(.scalar(.float), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }

    public mutating func encode(_ value: Double, forKey key: Key) throws {
        encoder.store(.scalar(.double), at: components(forKey: key))
        self.container[key.stringValue] = self.encoder.box(value)
    }

    public mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        encoder.store(try T.typeInformation(), at: components(forKey: key))
        self.encoder.codingPath.append(key)
        defer { self.encoder.codingPath.removeLast() }
        self.container[key.stringValue] = try self.encoder.box(value)
    }

    public mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> {
        let containerKey = key.stringValue
        let dictionary: NSMutableDictionary
        if let existingContainer = self.container[containerKey] {
            precondition(
                existingContainer is NSMutableDictionary,
                "Attempt to re-encode into nested KeyedEncodingContainer<\(Key.self)> for key \"\(containerKey)\" is invalid: non-keyed container already encoded for this key"
            )
            dictionary = existingContainer as! NSMutableDictionary
        } else {
            dictionary = NSMutableDictionary()
            self.container[containerKey] = dictionary
        }

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }

        let container = JSONKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)
        return KeyedEncodingContainer(container)
    }

    public mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let containerKey = key.stringValue
        let array: NSMutableArray
        if let existingContainer = self.container[containerKey] {
            precondition(
                existingContainer is NSMutableArray,
                "Attempt to re-encode into nested UnkeyedEncodingContainer for key \"\(containerKey)\" is invalid: keyed container/single value already encoded for this key"
            )
            array = existingContainer as! NSMutableArray
        } else {
            array = NSMutableArray()
            self.container[containerKey] = array
        }

        self.codingPath.append(key)
        defer { self.codingPath.removeLast() }
        return JSONUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
    }

    public mutating func superEncoder() -> Encoder {
        JSONReferencingEncoder(referencing: self.encoder, key: JSONKey.super, wrapping: self.container)
    }

    public mutating func superEncoder(forKey key: Key) -> Encoder {
        JSONReferencingEncoder(referencing: self.encoder, key: key, wrapping: self.container)
    }
}

extension Array where Element == CodingKey {
    func nonJSONKeys() -> Self {
        filter { !($0 is JSONKey) }
    }
    
    static func + (lhs: Self, rhs: Element) -> Self {
        var mutableLhs = lhs
        mutableLhs.append(rhs)
        return mutableLhs
    }
}
