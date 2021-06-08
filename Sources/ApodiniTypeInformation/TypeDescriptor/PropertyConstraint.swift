//
//  File.swift
//  
//
//  Created by Eldi Cano on 07.06.21.
//

import Foundation

/// Distinct cases of constraints of an object property
public enum PropertyConstraint {
    /// A required property
    case required
    /// An optional property
    case optional
    /// A repeated property (array)
    case repeated
}

// MARK: - TypeInformation
extension TypeInformation {
    /// Returns `self` with the context of `propertyConstraint`
    func with(_ propertyConstraint: PropertyConstraint) -> Self {
        switch propertyConstraint {
        case .optional:
            return asOptional
        case .repeated:
            return .repeated(element: self)
        default:
            return self
        }
    }
}
