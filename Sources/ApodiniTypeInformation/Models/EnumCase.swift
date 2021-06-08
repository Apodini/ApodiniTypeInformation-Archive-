import Foundation

/// Distinct cases or supported raw value types for enums
public enum RawValueType: String, Value {
    /// Int
    case int
    /// String
    case string
    
    init<R: RawRepresentable>(_ rawRepresentable: R.Type) {
        let rawValueTypeString = String(describing: R.RawValue.self)
        if let rawValueType = Self(rawValue: rawValueTypeString.lowerFirst) {
            self = rawValueType
        } else {
            fatalError("\(R.RawValue.self) is currently not supported")
        }
    }
}

/// Represents an enum case
public struct EnumCase: Value {
    /// Name of the case
    public let name: String
    /// JSON string of the raw value
    public let rawValue: String
    
    /// Initializes an enum case with the specified name
    public init(_ name: String) {
        self.name = name
        self.rawValue = name.json
    }
    
    /// Initializes an enum case with the specified name and rawValue
    public init (_ name: String, rawValue: String) {
        self.name = name
        self.rawValue = rawValue
    }
}

public extension EnumCase {
    /// Returns an enum case with the specified name
    static func `case`(_ name: String) -> EnumCase {
        .init(name)
    }
}
