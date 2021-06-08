import Foundation

/// A typealias form `Set<PartialTypeInformation>`
typealias CollectedTypeInfos = Set<PartialTypeInformation>

class TypeInformationCollector {
    /// Collected Partial type informations during encoding
    var storage: CollectedTypeInfos = []
    
    /// storage count
    var count: Int {
        storage.count
    }
    
    /// Creates a new partial typeInformation with components and stores it in `storage`
    func store(_ typeInformation: TypeInformation, at components: [String]) {
        let parentComponents = Array(components.dropLast())
        /// Internal dictionary encodable implementation uses a custom coding key for its keys, and encodes it again
        /// in the keyed container. If we encounter such a case, we ignore it because we have already stored that typeInformation
        if storage.firstMatch(on: \.components, with: parentComponents)?.typeInformation.dictionaryValue == typeInformation {
            return
        }
        
        storage.insert(.init(components: components, typeInformation: typeInformation, index: count))
    }
    
    func typeInformation(of type: Any.Type) throws -> TypeInformation {
        let properties: [TypeProperty] = storage.compactMap { current -> TypeProperty? in
            if current.isRoot {
                current.collectProperties(from: storage)
                return .property(current.absolutePath, type: current.typeInformation)
            }
            return nil
        }
        
        assert(storage.filter { $0.isUnassigned }.isEmpty, "Encountered unassigned children")
        
        let typeInformation: TypeInformation = try .withoutProperties(for: type)
        return typeInformation.withProperties(properties)
    }
}

/// An object created during encoding a value from `_JSONEncoder` at a specific path
class PartialTypeInformation {
    /// String components of the path where the type information has been boxed from the encoder
    let components: [String]
    /// The typeInformation of the path, if it is an object, properties are not included
    var typeInformation: TypeInformation
    /// Index of `self` in `TypeInformationCollector` of Encoder that created `self`
    let index: Int
    /// Parent where `self` has been assigned during `TypeInformation` construction
    private(set) var parent: PartialTypeInformation?
    
    /// String absoulute path of `self`
    let absolutePath: String
    
    /// Depth of `self`, a.k.a length of `components`
    var depth: Int {
        components.count
    }
    
    /// Indicates whether `self` is at root of the to be constructed `TypeInformation` (direct property of it)
    var isRoot: Bool {
        depth <= 1
    }
    
    /// Indicates whether `self` has not been assigned to any parent, after `collectProperties(from:)` of `CollectedTypeInfos`
    var isUnassigned: Bool {
        !isRoot && parent == nil
    }
    
    /// Initialiazes `self` with `components`, `typeInformation` and index
    init(components: [String], typeInformation: TypeInformation, index: Int) {
        self.components = components
        self.absolutePath = components.joined(separator: "/")
        self.typeInformation = typeInformation
        self.index = index
    }
    
    func collectProperties(from storage: CollectedTypeInfos) {
        let children = storage.filter { isDirectParent(of: $0) }
        guard parent == nil, !children.isEmpty else {
            return
        }
        let properties: [TypeProperty] = children.map { child in
            child.collectProperties(from: storage)
            let name = child.components[components.count]
            child.injectParent(self)
            return .property(name, type: child.typeInformation)
        }
        
        if typeInformation.nestedType.isObject {
            typeInformation = typeInformation.withProperties(properties)
        }
    }
    
    func isDirectParent(of partialTypeInformation: PartialTypeInformation) -> Bool {
        guard depth < partialTypeInformation.depth else {
            return false
        }
        
        return components == Array(partialTypeInformation.components[0..<depth])
            && depth == partialTypeInformation.depth - 1
    }
    
    func injectParent(_ parent: PartialTypeInformation) {
        self.parent = parent
    }
}

// MARK: - Equatable
extension PartialTypeInformation: Equatable {
    static func == (lhs: PartialTypeInformation, rhs: PartialTypeInformation) -> Bool {
        lhs.components == rhs.components
            && lhs.typeInformation == rhs.typeInformation
            && lhs.index == rhs.index
            && lhs.parent == rhs.parent
    }
}

// MARK: - Hashable
extension PartialTypeInformation: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(components)
        hasher.combine(typeInformation)
        hasher.combine(index)
        hasher.combine(parent)
    }
}
