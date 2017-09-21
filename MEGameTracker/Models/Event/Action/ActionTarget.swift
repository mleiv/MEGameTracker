//
//  ActionTarget.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import CoreData

/// Defines the target object of an event and the actions available against it.
public struct ActionTarget: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case type
    }

// MARK: Properties
    public var id: String
	public var type: ActionTargetObject

// MARK: Initialization
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(ActionTargetObject.self, forKey: .type)
    }
}

// MARK: Basic Actions
extension ActionTarget {

	/// Given a set of simple change commands in key-value format, executes a change against the specified object.
	public func change(fromActionData data: [String: Any?]) {
		switch type {
		case .decision:
			_ = getObject(type: Decision.self)?.changed(fromActionData: data)
		case .item:
            _ = getObject(type: Item.self)?.changed(fromActionData: data)
		case .mission:
            _ = getObject(type: Mission.self)?.changed(fromActionData: data)
		}
	}

	/// Fetches an object of the specified type and id
	private func getObject<T: GameRowStorable>(type: T.Type) -> T? {
		return T.getFromData { fetchRequest in
				fetchRequest.predicate = NSPredicate(
					format: "(id = %@)",
					self.id
				)
			}
	}

	/// Determine if this action targets the source specified.
	public func isMatch(source: Any?) -> Bool {
		if let decision = source as? Decision {
			return decision.id == id
		}
		if let mission = source as? Mission {
			return mission.id == id
		}
		if let item = source as? Item {
			return item.id == id
		}
		return false
	}
}
