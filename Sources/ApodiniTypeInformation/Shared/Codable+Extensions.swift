import Foundation

// MARK: - Encodable extensions
public extension Encodable {
    /// JSON String of `self with `.prettyPrinted` output formatting
    var json: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        let data = (try? encoder.encode(self)) ?? Data()
        return String(decoding: data, as: UTF8.self)
    }
}

// MARK: - Internal
extension Encodable {
    /// The corresponding typeInformation instance of `Self` without properties if it is an object
    static func typeInformation() throws -> TypeInformation {
        try .withoutProperties(for: Self.self)
    }
}


// MARK: - KeyedEncodingContainerProtocol
extension KeyedEncodingContainerProtocol {
    /// Only encodes the value if the collection is not empty
    public mutating func encodeIfNotEmpty<T: Encodable>(_ value: T, forKey key: Key) throws where T: Collection, T.Element: Encodable {
        if !value.isEmpty {
            try encode(value, forKey: key)
        }
    }
}

// MARK: - KeyedDecodingContainerProtocol
extension KeyedDecodingContainerProtocol {
    /// Decodes a value of the given collection type for the given key, if present, otherwise initalizes it as empty collection
    public func decodeIfPresentOrInitEmpty<T: Decodable>(_ type: T.Type, forKey key: Key) throws -> T where T: Collection, T.Element: Decodable {
        // swiftlint:disable:next force_cast
        (try decodeIfPresent(T.self, forKey: key)) ?? [] as! T
    }
}
