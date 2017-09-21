//
//  Action.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/27/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Stores the properties necessary to execute automatic changes to objects based on events.
public struct Action: Codable {

    enum CodingKeys: String, CodingKey {
        case target
        case changes
    }

// MARK: Properties
	/// An identifier for the type of target to be changed.
	public var target: ActionTarget

	/// A set of change instructions in basic key-value form.
	public var changes: CodableDictionary

// MARK: Initialization
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        target = try container.decode(ActionTarget.self, forKey: .target)
        changes = try container.decode(CodableDictionary.self, forKey: .changes)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(target, forKey: .target)
        try container.encode(changes, forKey: .changes)
    }
}

// MARK: Basic Actions
extension Action {

	/// Executes or reverts the change.
	public func change(isTriggered: Bool) {
		target.change(fromActionData: isTriggered ? onChanges : offChanges)
	}

	public var onChanges: [String: Any?] {
        return (changes["On"] as? CodableDictionary)?.dictionary ?? [:]
	}

    public var offChanges: [String: Any?] {
        return (changes["Off"] as? CodableDictionary)?.dictionary ?? [:]
    }

}
