//
//  IdentifyingObject.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/21/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

extension Note {

    public enum IdentifyingObject {
    
        case decision(id: String)
        case item(id: String)
        case map(id: String)
        case mission(id: String)
        case note(uuid: String)
        case person(id: String)
        case shepard
        
// MARK: Computed Properties

        /// Object type.
        public var type: String {
            switch self {
                case .decision(_): return "Decision"
                case .item(_): return "Item"
                case .note(_): return "Note"
                case .map(_): return "Map"
                case .mission(_): return "Mission"
                case .person(_): return "Person"
                case .shepard(_): return "Shepard"
            }
        }
        
        /// Object id.
        public var id: String {
            switch self {
                case .decision(let x): return x
                case .item(let x): return x
                case .note(let x): return x
                case .map(let x): return x
                case .mission(let x): return x
                case .person(let x): return x
                case .shepard: return ""
            }
        }
        
        /// Persistent store value for lookup.
        public var flattenedString: String {
            return "\(type)\(id)"
        }
        
// MARK: Initialization

        public init?(objectType: String, objectId: String = "") {
            switch objectType {
                case "Decision": self = .decision(id: objectId)
                case "Item": self = .item(id: objectId)
                case "Map": self = .map(id: objectId)
                case "Mission": self = .mission(id: objectId)
                case "Note": self = .note(uuid: objectId)
                case "Person": self = .person(id: objectId)
                case "Shepard": self = .shepard
                default: return nil
            }
        }
        
// MARK: Faux SerializedDataStorable

        public init?(data: SerializableData?) {
            if let type = data?["type"]?.string, let id = data?["id"]?.string {
                self.init(objectType: type, objectId: id)
            } else {
                return nil
            }
        }
        
// MARK: Faux SerializedDataRetrievable

        public var serializedString: String { return self.getData().jsonString }

        public init?(serializedString json: String) {
            self.init(data: try? SerializableData(serializedString: json))
        }
        
        public func getData() -> SerializableData {
            var list: [String: SerializedDataStorable?] = [:]
            list["type"] = type
            list["id"] = id
            return SerializableData.safeInit(list)
        }
    }
}


//MARK: Equatable

extension Note.IdentifyingObject: Equatable {}

public func ==(lhs: Note.IdentifyingObject, rhs: Note.IdentifyingObject) -> Bool {
    switch (lhs, rhs) {
        case (.decision(let a),.decision(let b)): return a == b
        case (.item(let a),.item(let b)): return a == b
        case (.note(let a),.note(let b)): return a == b
        case (.map(let a),.map(let b)): return a == b
        case (.mission(let a),.mission(let b)): return a == b
        case (.person(let a),.person(let b)): return a == b
        case (.shepard, .shepard): return true
        default: return false
    }
}
