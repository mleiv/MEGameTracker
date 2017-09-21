//
//  ConversationRewards.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/26/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

// MARK: ConversationRewardSet
public struct ConversationRewardSet: Codable {

    enum CodingKeys: String, CodingKey {
        case set
    }
    enum SetCodingKeys: String, CodingKey {
        case context
        case isExclusiveSet
        case options
    }

// MARK: Properties

	// only one of next two may be set:

	/// Option A) A list of choices (not a terminating element in a choices hierarchy branch).
	public var subset: [ConversationRewardSet]?
	/// Option B) A single choice (always the terminating element in a choices hierarchy branch).
	public var point: ConversationReward?

	/// Context string applied to any immediate choices contained in this morality set.
	public var commonContext: String?

	/// Indicates if our subset allows free selection, or limits to a single choice
	public var isExclusiveSet = false

// MARK: Computed Properties

	/// Returns true when the end of the branch is reached.
	public var isEmpty: Bool {
		return point == nil && subset?.isEmpty != false
	}

// MARK: Initialization
    public init(from decoder: Decoder) throws {
        if let extractedPoint = try? ConversationReward(from: decoder) {
            subset = nil
            point = extractedPoint
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let setContainer = try container.nestedContainer(keyedBy: SetCodingKeys.self, forKey: .set)
            point = nil
            commonContext = try setContainer.decodeIfPresent(String.self, forKey: .context)
            subset = try setContainer.decodeIfPresent([ConversationRewardSet].self, forKey: .options) ?? []
            isExclusiveSet = try setContainer.decodeIfPresent(Bool.self, forKey: .isExclusiveSet) ?? isExclusiveSet
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let subset = subset {
            var container = encoder.container(keyedBy: CodingKeys.self)
            var setContainer = container.nestedContainer(keyedBy: SetCodingKeys.self, forKey: .set)
            try setContainer.encode(commonContext, forKey: .context)
            try setContainer.encode(subset, forKey: .options)
            try setContainer.encode(isExclusiveSet, forKey: .isExclusiveSet)
        } else {
            try point?.encode(to: encoder)
        }
    }
}

// MARK: Basic Actions
extension ConversationRewardSet {

	/// Sums up all the available morality points for a set of conversation rewards.
	public func sum(type: ConversationRewardType) -> Int {
		// TODO - consider exclusivity: kaidan/ashley with only one avenue, only 2/2, not 4/4
		if let points = point?.value, point?.type == type {
			return points
		}
		if point?.type == .paragade && point?.paragadeValue.count == 2 {
			return (type == .paragon ? point?.paragadeValue[0] : point?.paragadeValue[1]) ?? 0
		} else if let points = point?.value, type == .neutral && point?.type == .paragade && points > 0 {
			// game 3 neutral reputation points
			return points
		}
		return (subset ?? []).reduce(0) { $0 + $1.sum(type: type) }
	}

	/// Flattens a set of choices to rows suitable for UI display.
	public func flatRows(level: Int = 0) -> [ConversationRewards.FlatData] {
		if let point = self.point {
			let points: String
			if point.type == .paragade && point.paragadeValue.count == 2 {
				points = point.paragadeValue.map({ "\($0)" }).joined(separator: "/")
			} else {
				points = "\(point.value)"
			}
			let options: [ConversationRewards.FlatDataOption] = [(
				id: point.id,
				type: point.type,
				points: points,
				context: point.context,
				trigger: point.trigger,
				isSelected: point.isSelected
			)]
//			print("OPTION: \(commonContext) \(options.first?.context) \(options.first?.trigger)")
			return [(level: level, commonContext: commonContext, options: options)]
		} else {
			let nextLevel = level + 1
			let returnRows: [ConversationRewards.FlatData]
			let subset = self.subset ?? []
			let recursedOptions = subset.flatMap { $0.flatRows(level: nextLevel) }
			let hasOnlyOneLevel: Bool = subset.reduce(true) { $0 && ($1.subset?.isEmpty ?? true) }
			if hasOnlyOneLevel && (isExclusiveSet || recursedOptions.count == 1) {
				// insert into same row
				let nextOptions = recursedOptions.flatMap({ $0.options.first })
				returnRows = [(level: level, commonContext: commonContext, options: nextOptions)]
			} else if let context = commonContext {
				let contextRow: [ConversationRewards.FlatData] = [(level: level, commonContext: context, options: [])]
				returnRows = contextRow + recursedOptions
			} else {
				returnRows = recursedOptions
			}
//			print("ROW: \(level) \(commonContext) totalRows: \(returnRows.count)")
			return returnRows
		}
	}

	/// Returns a list of all selected choices for persistant storage.
	public func selectedIds() -> [String] {
		var selectedIds: [String] = []
		for point in (subset ?? []) {
			selectedIds += point.selectedIds()
		}
		if point?.isSelected == true, let id = point?.id {
			selectedIds.append(id)
		}
		return selectedIds
	}

	/// Applies a set of selected choices to the tree.
	public mutating func setSelectedIds(_ ids: [String]) {
		if point != nil && ids.contains(point?.id ?? "") {
			point?.isSelected = true
		}
		for index in (subset ?? []).indices {
			subset?[index].setSelectedIds(ids)
		}
	}

	/// Selects one conversation choice.
	public mutating func setSelectedId(_ id: String) -> Bool {
		if point != nil && id == point?.id {
			self.point?.isSelected = true
			return true
		}
		for index in (subset ?? []).indices where subset?[index].setSelectedId(id) == true {
			if isExclusiveSet {
				// unset any other elements
				for index2 in (subset ?? []).indices where index2 != index {
					subset?[index2].unsetSelectedIds()
				}
			}
			return true
		}
		return false
	}

	/// Unselects one conversation choice.
	public mutating func unsetSelectedId(_ id: String) -> Bool {
		if point != nil && id == point?.id {
			self.point?.isSelected = false
			return true
		}
		for index in (subset ?? []).indices where subset?[index].unsetSelectedId(id) == true {
			return true
		}
		return false
	}

	/// Erases all selected choices.
	internal mutating func unsetSelectedIds() {
		self.point?.isSelected = false
		for index in (subset ?? []).indices {
			subset?[index].unsetSelectedIds()
		}
	}
}

//// MARK: SerializedDataStorable
//extension ConversationRewardSet: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        if let exclusiveSet = self.subset {
//            let exclusiveSetList: [String: SerializedDataStorable?] = [
//                "context": commonContext,
//                "options": SerializableData.safeInit(exclusiveSet),
//                "isExclusiveSet": isExclusiveSet,
//            ]
//            var list: [String: SerializedDataStorable?] = [:]
//            list["set"] = SerializableData.safeInit(exclusiveSetList)
//            return SerializableData.safeInit(list)
//        } else {
//            return point?.getData() ?? SerializableData()
//        }
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension ConversationRewardSet: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data
//        else {
//            return nil
//        }
//        if let exclusiveSetList = data["set"]?["options"]?.array {
//            subset = []
//            point = nil
//            commonContext = data["set"]?["context"]?.string
//            for setData in exclusiveSetList {
//                if let set = ConversationRewardSet(data: setData) {
//                    subset?.append(set)
//                }
//            }
//            isExclusiveSet = data["set"]?["isExclusiveSet"]?.bool ?? isExclusiveSet
//        } else {
//            subset = nil
//            point = ConversationReward(data: data)
//        }
//        if subset == nil && point == nil {
//            return nil
//        }
//    }
//
//    public mutating func setData(_ data: SerializableData) {}
//
//}
