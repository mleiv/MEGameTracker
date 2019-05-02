//
//  CodableDictionaryValueType.swift
//  MEGameTracker
//
//  Copyright © 2017 Emily Ivie.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import Foundation

/// A wrapper for the permitted Codable value types.
/// Permits generic dictionary encoding/decoding when used with CodableDictionary.
public enum CodableDictionaryValueType: Codable {
    case uuid(UUID)
    case bool(Bool)
    case int(Int)
    case double(Double)
    case float(Float)
    case date(Date)
    case string(String)
    case data(Data)
    indirect case dictionary(CodableDictionary)
    indirect case array([CodableDictionaryValueType])
    case empty

    //    public init(_ value: Date) { self = .date(value) }
    //    public init(_ value: UUID) { self = .uuid(value) }
    //    public init(_ value: Int) { self = .int(value) }
    //    public init(_ value: Float) { self = .float(value) }
    //    public init(_ value: Bool) { self = .bool(value) }
    //    public init(_ value: String) { self = .string(value) }
    //    public init(_ value: Data) { self = .data(value) }
    //    public init(_ value: CodableDictionary) { self = .dictionary(value) }
    //    // nil?

    public init(_ value: Any?) {
        self = {
            if let value = value as? CodableDictionaryValueType {
                return value
            } else if let value = value as? UUID {
                return .uuid(value)
            } else if let value = value as? Bool {
                return .bool(value)
            } else if let value = value as? Int {
                return .int(value)
            } else if let value = value as? Double {
                // FYI, Int values are currently encoded to double in CK :(
                return .double(value)
            } else if let value = value as? Float {
                return .float(value)
            } else if let value = value as? Date {
                return .date(value)
            } else if let value = value as? Data {
                return .data(value)
            } else if let value = value as? String {
                return .string(value)
            } else if let value = value as? CodableDictionary {
                return .dictionary(value)
            } else if let value = value as? [Any?] {
                return .array(value.map {
                    guard let row = $0 else { return .empty }
                    if let d = row as? [String: Any?] {
                        return CodableDictionaryValueType(CodableDictionary(d))
                    } else {
                        return CodableDictionaryValueType(row)
                    }
                })
            } else {
                return .empty
            }
        }()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = {
            if let value = try? container.decode(CodableDictionary.self) {
                return .dictionary(value)
            } else if let value = try? container.decode([CodableDictionaryValueType].self) {
                return .array(value)
            } else if let value = try? container.decode(UUID.self) {
                return .uuid(value)
            } else if let value = try? container.decode(Bool.self) {
                return .bool(value)
            } else if let value = try? container.decode(Int.self) {
                return .int(value)
            } else if let value = try? container.decode(Double.self) {
                return .double(value)
            } else if let value = try? container.decode(Float.self) {
                return .float(value)
            } else if let value = try? container.decode(Date.self) {
                return .date(value)
            } else if let value = try? container.decode(Data.self) {
                if let stringValue = try? container.decode(String.self),
                    ["Triggers", "BlockedUntil"].contains(stringValue) { // I can't even...
                    return .string(stringValue)
                }
                return .data(value)
            } else if let value = try? container.decode(String.self) {
                return .string(value)
            } else {
                return .empty
            }
        }()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .uuid(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        case .int(let value): try container.encode(value)
        case .double(let value): try container.encode(value)
        case .float(let value): try container.encode(value)
        case .date(let value): try container.encode(value)
        case .data(let value): try container.encode(value)
        case .string(let value): try container.encode(value)
        case .dictionary(let value): try container.encode(value)
        case .array(let value): try container.encode(value)
        default: try container.encodeNil()
        }
    }

    public var value: Any? {
        switch self {
        case .uuid(let value): return value
        case .bool(let value): return value
        case .int(let value): return value
        case .double(let value): return value
        case .float(let value): return value
        case .date(let value): return value
        case .data(let value): return value
        case .string(let value): return value
        case .dictionary(let value): return value
        case .array(let value): return value.map { $0.value }
        default: return nil
        }
    }
}
extension CodableDictionaryValueType: CustomDebugStringConvertible {
    public var debugDescription: String { return String(describing: value) }
}
extension CodableDictionaryValueType: CustomStringConvertible {
    public var description: String { return String(describing: value) }
}
