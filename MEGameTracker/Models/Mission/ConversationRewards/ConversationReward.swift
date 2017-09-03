//
//  ConversationReward.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// A single conversation event and its reward.
public struct ConversationReward: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case value
        case paragadeValue
        case type
        case context
        case trigger
//        case isSelected
    }

	public var id: String
	public var value: Int
	public var paragadeValue: [Int] = []
	public var type: ConversationRewardType
	public var context: String?
	public var trigger: String
	public var isSelected = false

// MARK: Initialization
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(Int.self, forKey: .value)
        type = try container.decode(ConversationRewardType.self, forKey: .type)
        trigger = try container.decode(String.self, forKey: .trigger)
        context = try container.decodeIfPresent(String.self, forKey: .context)
        paragadeValue = try container.decodeIfPresent([Int].self, forKey: .paragadeValue) ?? []
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(value, forKey: .value)
        try container.encode(type, forKey: .type)
        try container.encode(trigger, forKey: .trigger)
        try container.encode(context, forKey: .context)
        try container.encode(paragadeValue, forKey: .paragadeValue)
    }
}

//// MARK: SerializedDataStorable
//extension ConversationReward: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        var list: [String: SerializedDataStorable?] = [:]
//        list["id"] = id
//        list["value"] = value
//        list["paragadeValue"] = SerializableData.safeInit(paragadeValue as [SerializedDataStorable])
//        list["type"] = type.stringValue
//        list["context"] = context
//        list["trigger"] = trigger
//        return SerializableData.safeInit(list)
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension ConversationReward: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data,
//                  let id = data["id"]?.string,
//                  let value = data["value"]?.int,
//                  let type = ConversationRewardType(stringValue: data["type"]?.string),
//                  let trigger = data["trigger"]?.string
//        else {
//            return nil
//        }
//        self.id = id
//        self.value = value
//        self.paragadeValue = (data["paragadeValue"]?.array ?? []).map({ $0.int }).filter({ $0 != nil }).map({ $0! })
//        self.type = type
//        self.context = data["context"]?.string
//        self.trigger = trigger
//    }
//
//    public mutating func setData(_ data: SerializableData) {}
//}
