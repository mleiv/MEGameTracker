//
//  ConversationRewards.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/26/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Defines a set of dialogue choices or actions which result in morality rewards (or alternatively, currency).
/// It is a very complicated tree with elements that block each other.
public struct ConversationRewards: Codable {

// MARK: Types

	public typealias FlatDataOption = (
		id: String?,
		type: ConversationRewardType,
		points: String,
		context: String?,
		trigger: String,
		isSelected: Bool
	)
	public typealias FlatData = (
		level: Int,
		commonContext: String?,
		options: [ConversationRewards.FlatDataOption]
	)

// MARK: Properties

	public var points: [ConversationRewardSet] = []
	public init() {}

// MARK: Computed Properties

	public var isEmpty: Bool {
		return points.reduce(true) { $0 && $1.isEmpty }
	}

// MARK: Initialization
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        points = try container.decode([ConversationRewardSet].self)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(points)
    }
}

// MARK: Basic Actions
extension ConversationRewards {

	/// Sums all the conversation rewards points in the tree.
	public func sum(type: ConversationRewardType) -> Int {
		return points.reduce(0) { $0 + $1.sum(type: type) }
	}

	/// Flattens the choices to rows suitable for UI display.
	public func flatRows() -> [ConversationRewards.FlatData] {
		return points.flatMap({ $0.flatRows(level: 0) })
	}

	/// Returns a list of all selected choices for persistant storage.
	public func selectedIds() -> [String] {
		return points.flatMap({ $0.selectedIds() })
	}

	/// Applies a set of selected choices to the tree.
	public mutating func setSelectedIds(_ ids: [String]) {
		for index in points.indices {
			points[index].unsetSelectedIds()
		}
		for index in points.indices {
			points[index].setSelectedIds(ids)
		}
	}

	/// Selects one conversation choice.
	public mutating func setSelectedId(_ id: String) {
		for index in points.indices where points[index].setSelectedId(id) {
			break
		}
	}

	/// Unselects one conversation choice.
	public mutating func unsetSelectedId(_ id: String) {
		for index in points.indices where points[index].unsetSelectedId(id) {
			break
		}
	}
}

//// MARK: SerializedDataStorable
//extension ConversationRewards: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        return SerializableData.safeInit(points as [SerializedDataStorable])
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension ConversationRewards: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data, (data.array ?? []).count > 0
//        else {
//            return nil
//        }
//        points = []
//        for setData in (data.array ?? []) {
//            if let set = ConversationRewardSet(data: setData) {
//                points.append(set)
//            }
//        }
//    }
//
//    public mutating func setData(_ data: SerializableData) {}
//}

