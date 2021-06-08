//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.06.21.
//

import Foundation

/// An enum type descriptor with `Model: Encodable & RawRepresentable` and `Model.RawValue: Encodable` generic constraints
public class EnumTypeDescriptor<Model: Encodable & RawRepresentable>: TypeDescriptor where Model.RawValue: Encodable {
    /// A typealias for `Model.RawValue`
    public typealias RawValue = Model.RawValue
    
    /// Registered cases of `self`
    var cases: [EnumCase]
    
    /// Initialzer for an `EnumTypeDescriptor`
    public init() {
        precondition(type(Model.self, isAnyOf: .enum), "\(Model.self) must be an enum")
        
        cases = []
    }
    
    /// Registers an enum case in `self`
    /// - Parameters:
    ///   - case: the case of enum to be registered
    ///   - rawValue: the assigned `rawValue` of the `case`
    /// - Returns: `self` after registering the case
    public func `case`(_ `case`: Model) -> Self {
        assert(`case`)
        
        cases.append(.init("\(`case`)", rawValue: `case`.rawValue.json))
        return self
    }
    
    /// Registers an enum case in `self` for `RawValue` of type `String`
    /// - Parameters:
    ///   - case: the case of enum to be registered
    ///   - rawValue: the assigned string `rawValue` of the `case`. Parameter can be ommitted if the `rawValue` corresponds to `case`
    /// - Returns: `self` after registering the case
    
    /// Asserts the uniqueness of the to be registered `case`
    /// - Parameters:
    ///   - `case`: the case of the enum
    private func assert(_ `case`: Model) {
        precondition(!cases.map { $0.name }.contains("\(`case`)"), "Case \(`case`) of \(Model.self) has been already registered")
    }
}

// MARK: - _TypeDescriptor
extension EnumTypeDescriptor: _TypeDescriptor {
    /// The corresponding `typeInformation` instance of `self`
    var typeInformation: TypeInformation {
        .enum(model: Model.self, cases: cases)
    }
}
