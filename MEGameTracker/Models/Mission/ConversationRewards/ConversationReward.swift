//
//  ConversationReward.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// A single conversation event and its reward.
public struct ConversationReward {
	public var id: String
	public var value: Int
	public var paragadeValue: [Int] = []
	public var type: ConversationRewardType
	public var context: String?
	public var trigger: String
	public var isSelected = false
}

// MARK: SerializedDataStorable
extension ConversationReward: SerializedDataStorable {

	public func getData() -> SerializableData {
		var list: [String: SerializedDataStorable?] = [:]
		list["id"] = id
		list["value"] = value
		list["paragadeValue"] = SerializableData.safeInit(paragadeValue as [SerializedDataStorable])
		list["type"] = type.stringValue
		list["context"] = context
		list["trigger"] = trigger
		return SerializableData.safeInit(list)
	}

}

// MARK: SerializedDataRetrievable
extension ConversationReward: SerializedDataRetrievable {

	public init?(data: SerializableData?) {
		guard let data = data,
				  let id = data["id"]?.string,
				  let value = data["value"]?.int,
				  let type = ConversationRewardType(stringValue: data["type"]?.string),
				  let trigger = data["trigger"]?.string
		else {
			return nil
		}
		self.id = id
		self.value = value
		self.paragadeValue = (data["paragadeValue"]?.array ?? []).map({ $0.int }).filter({ $0 != nil }).map({ $0! })
		self.type = type
		self.context = data["context"]?.string
		self.trigger = trigger
	}

    public mutating func setData(_ data: SerializableData) {}
}
