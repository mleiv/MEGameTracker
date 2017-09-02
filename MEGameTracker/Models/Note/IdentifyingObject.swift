//
//  IdentifyingObject.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/21/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

extension Note {

	public enum IdentifyingObject: Codable {

        enum CodingKeys: String, CodingKey {
            case type
            case id
        }

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
				case .shepard: return "Shepard"
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

		/// Persistent store value for lookup in CoreData.
		public var flattenedString: String {
			return "\(type)\(id)"
		}

        /// Persistent store value for storage in cloud.
        public var serializedString: String {
            let data = (try? CoreDataManager.current.encoder.encode(self)) ?? Data()
            return String(data: data, encoding: .utf8) ?? ""
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

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            let id = try container.decodeIfPresent(String.self, forKey: .id)
            self.init(objectType: type, objectId: id ?? "")!
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(type, forKey: .type)
            try container.encode(id, forKey: .id)
        }
	}
}

// MARK: Equatable
extension Note.IdentifyingObject: Equatable {}

public func == (lhs: Note.IdentifyingObject, rhs: Note.IdentifyingObject) -> Bool {
	switch (lhs, rhs) {
		case (.decision(let lhsId), .decision(let rhsId)): return lhsId == rhsId
		case (.item(let lhsId), .item(let rhsId)): return lhsId == rhsId
		case (.note(let lhsId), .note(let rhsId)): return lhsId == rhsId
		case (.map(let lhsId), .map(let rhsId)): return lhsId == rhsId
		case (.mission(let lhsId), .mission(let rhsId)): return lhsId == rhsId
		case (.person(let lhsId), .person(let rhsId)): return lhsId == rhsId
		case (.shepard, .shepard): return true
		default: return false
	}
}
