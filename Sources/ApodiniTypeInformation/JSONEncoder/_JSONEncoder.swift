//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2017 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

import Foundation

class _JSONEncoder: Encoder {
    // MARK: Properties

    /// The encoder's storage.
    var storage: Storage
    
    var typeInformationCollector: TypeInformationCollector
    
    var rootType: Any.Type?
    
    var requestedTopLevelContainer: RootContainerType?

    /// The path to the current point in encoding.
    public var codingPath: [CodingKey]
    
    /// Contextual user-provided information for use during encoding.
    public var userInfo: [CodingUserInfoKey: Any] = [:]
    // MARK: - Initialization

    /// Initializes `self` with the given top-level encoder options.
    init(codingPath: [CodingKey] = []) {
        self.storage = Storage()
        self.codingPath = codingPath
        self.typeInformationCollector = .init()
    }

    /// Returns whether a new element can be encoded at this coding path.
    ///
    /// `true` if an element has not yet been encoded at this coding path; `false` otherwise.
    var canEncodeNewValue: Bool {
        // Every time a new value gets encoded, the key it's encoded for is pushed onto the coding path (even if it's a nil key from an unkeyed container).
        // At the same time, every time a container is requested, a new value gets pushed onto the storage stack.
        // If there are more values on the storage stack than on the coding path, it means the value is requesting more than one container, which violates the precondition.
        //
        // This means that anytime something that can request a new container goes onto the stack, we MUST push a key onto the coding path.
        // Things which will not request containers do not need to have the coding path extended for them (but it doesn't matter if it is, because they will not reach here).
        return self.storage.count == self.codingPath.count
    }

    // MARK: - Encoder Methods
    public func container<Key>(keyedBy: Key.Type) -> KeyedEncodingContainer<Key> {
        // If an existing keyed container was already requested, return that one.
        let topContainer: NSMutableDictionary
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushKeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableDictionary else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        setTopLevelContainerType(.keyedContainer)
        let container = JSONKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
        return KeyedEncodingContainer(container)
    }

    public func unkeyedContainer() -> UnkeyedEncodingContainer {
        // If an existing unkeyed container was already requested, return that one.
        let topContainer: NSMutableArray
        if self.canEncodeNewValue {
            // We haven't yet pushed a container at this level; do so here.
            topContainer = self.storage.pushUnkeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableArray else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }

            topContainer = container
        }

        setTopLevelContainerType(.unkeyedContainer)
        return JSONUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
    }

    public func singleValueContainer() -> SingleValueEncodingContainer {
        setTopLevelContainerType(.singleValueContainer)
        return self
    }
    
    func store(_ typeInformation: TypeInformation, at components: [String]) {
        typeInformationCollector.store(typeInformation, at: components)
    }
    
    func storeFromSingleValueContainer(_ typeInformation: TypeInformation, at components: [String]) {
    }
    
    func storeFromUnkeyedContainer(_ typeInformation: TypeInformation, at components: [String]) {
    }
    
    private func setTopLevelContainerType(_ rootContainerType: RootContainerType) {
        if requestedTopLevelContainer == nil {
            requestedTopLevelContainer = rootContainerType
        }
    }
    
    func typeInformation() throws -> TypeInformation {
        guard let rootType = rootType else {
            fatalError("Root type not injected")
        }
        
        let typeInformation = try typeInformationCollector.typeInformation(of: rootType)
        
        return requestedTopLevelContainer == .unkeyedContainer ? .repeated(element: typeInformation) : typeInformation
    }
}
