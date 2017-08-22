//
//  CodableDictionary.swift
//  MEGameTracker
//
//  Copyright © 2017 Emily Ivie.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.
//

import Foundation

/// Permits generic dictionary encoding/decoding when used with simple data types
/// (see CodableDictionaryValueType)
///
/// Example:
/// ```Swift
///    struct Test: Codable {
///        enum CodingKeys: String, CodingKey {
///            case genericList
///        }
///        var genericList: CodableDictionary
///        init(genericList: [String: Any?]) {
///            self.genericList = CodableDictionary(genericList)
///        }
///        init(from decoder: Decoder) throws {
///            let container = try decoder.container(keyedBy: CodingKeys.self)
///            genericList = try container.decodeIfPresent(
///                            CodableDictionary.self,
///                            forKey: .genericList
///                           ) ?? CodableDictionary()
///        }
///        // encode not required
///    }
///    let json = """
///            { "genericList": { "uuid": "\(UUID())" } }
///        """
///    let decodeList = try JSONDecoder().decode(Test.self, from: json.data(using: .utf8)!)
///    var encodeList = Test(genericList: ["uuid": UUID()])
///    String(data: try JSONEncoder().encode(encodeList), encoding: .utf8)
/// ```
///
/// Warning: boolean values must be written as true and false, not 1 and 0.
///     CodableDictionary does not recognize the abbreviated integer form.
public struct CodableDictionary {
    public typealias Key = String
    public typealias Value = CodableDictionaryValueType
    public typealias DictionaryType = [Key: Value]
    public var dictionary: [Key: Any?] {
        return Dictionary(uniqueKeysWithValues: internalDictionary.map {
            if let d = ($0.1).value as? CodableDictionary {
                return ($0.0, d.dictionary)
            } else {
                return ($0.0, ($0.1).value)
            }
        })
    }
    private var internalDictionary: DictionaryType
    public init(_ dictionary: [String: Any?] = [:]) {
        self.internalDictionary = Dictionary(uniqueKeysWithValues: dictionary.map {
            ($0.0, CodableDictionaryValueType($0.1))
        })
    }
}
extension CodableDictionary: Collection {
    public typealias IndexDistance = DictionaryType.IndexDistance
    public typealias Indices = DictionaryType.Indices
    public typealias Iterator = DictionaryType.Iterator
    public typealias SubSequence = DictionaryType.SubSequence

    public var startIndex: Index { return internalDictionary.startIndex }
    public var endIndex: DictionaryType.Index { return internalDictionary.endIndex }
    public subscript(position: Index) -> Iterator.Element { return internalDictionary[position] }
    public subscript(bounds: Range<Index>) -> SubSequence { return internalDictionary[bounds] }
    public var indices: Indices { return internalDictionary.indices }
    public subscript(key: Key) -> Any? {
        get { return internalDictionary[key]?.value ?? nil }
        set(newValue) { internalDictionary[key] = CodableDictionaryValueType(newValue) }
    }
    public func index(after index: Index) -> Index {
        return internalDictionary.index(after: index)
    }
    public func makeIterator() -> DictionaryIterator<Key, Value> {
        return internalDictionary.makeIterator()
    }
    public typealias Index = DictionaryType.Index
}
extension CodableDictionary:  ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (Key, Value)...) {
        internalDictionary = DictionaryType(uniqueKeysWithValues: elements)
    }
}
extension CodableDictionary: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        internalDictionary = try container.decode(DictionaryType.self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(internalDictionary)
    }
}
extension CodableDictionary: CustomDebugStringConvertible {
    public var debugDescription: String { return dictionary.debugDescription }
}
extension CodableDictionary: CustomStringConvertible {
    public var description: String { return dictionary.description }
}
