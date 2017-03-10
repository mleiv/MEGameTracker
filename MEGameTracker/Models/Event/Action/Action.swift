//
//  Action.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/27/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Stores the properties necessary to execute automatic changes to objects based on events.
public struct Action {

// MARK: Properties

	/// An identifier for the type of target to be changed.
	public var target: ActionTarget

	/// A set of change instructions in basic key-value form.
	public var changes: [String: SerializableData]
}

// MARK: Basic Actions
extension Action {

	/// Executes or reverts the change.
	public func change(isTriggered: Bool) {
		target.change(data: isTriggered ? changes["On"] : changes["Off"])
	}

}

// MARK: SerializedDataStorable
extension Action: SerializedDataStorable {

	public func getData() -> SerializableData {
		var list: [String: SerializedDataStorable?] = [:]
		list["target"] = target
		list["changes"] = SerializableData.safeInit(changes)
		return SerializableData.safeInit(list)
	}

}

// MARK: SerializedDataRetrievable
extension Action: SerializedDataRetrievable {

	public init?(data: SerializableData?) {
		guard let data = data,
			  let target = ActionTarget(data: data["target"]),
			  let changes = data["changes"]?.dictionary
		else {
			return nil
		}
		self.target = target
		self.changes = changes
	}

}
