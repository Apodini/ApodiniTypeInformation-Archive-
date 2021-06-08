//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.06.21.
//

import Foundation

/// A protocol for instances that provide some information regarding the structure of a type
public protocol TypeDescriptor {}


/// An internal type descriptor protocol
protocol _TypeDescriptor {
    var typeInformation: TypeInformation { get }
}


// MARK: - TypeDescriptor
extension TypeDescriptor {
    func typeInformation() -> TypeInformation {
        guard let self = self as? _TypeDescriptor else {
            fatalError("Encountered \(Self.self) that does not conform to '_TypeDescriptor'")
        }
        return self.typeInformation
    }
}
