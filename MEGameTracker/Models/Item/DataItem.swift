//
//  DataItem.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct DataItem: Codable, DataMapLocationable {

    enum CodingKeys: String, CodingKey {
        case id
        case gameVersion
        case name
        case itemType
        case itemDisplayType
        case description
        case price
        case sortIndex
        case relatedLinks
        case relatedDecisionIds
        case sideEffects
        case relatedMissionIds
        case photo
        case events
    }

// MARK: Constants

// MARK: Properties
    public var rawData: Data?
	public private(set) var id: String
	public private(set) var gameVersion: GameVersion
	private var _name: String = "Unknown"
	public var itemType: ItemType = .loot
	public var itemDisplayType: ItemDisplayType?
	public var description: String?
	public var price: String?

	public private(set) var relatedLinks: [String] = []
	public internal(set) var relatedDecisionIds: [String] = [] // transient changes in Mission
	public private(set) var sideEffects: [String] = []
	public private(set) var relatedMissionIds: [String] = []
	public private(set) var photo: Photo?

    public var rawEventDictionary: [CodableDictionary] = []

	// Interface Builder
	public var isDummyData = false

// MARK: Computed Properties
	public var name: String {
		return "\(itemType.titlePrefix)\(_name)"
	}

	public var hasNoAdditionalData: Bool {
		if relatedLinks.count > 0 {
			return false
		}
		if description != nil {
			return false
		}
		return true
	}

// MARK: MapLocationable
	public var annotationNote: String?

	public var mapLocationType = MapLocationType.item
	public var mapLocationPoint: MapLocationPoint?
	public var inMapId: String?
	public var inMissionId: String?
	public var sortIndex: Int = 0

	public var isHidden: Bool = false
	public var isAvailable: Bool = true
	public var unavailabilityMessages: [String] = []

//	public var searchableName: String // optional
//	public var linkToMapId: String? // optional
//	public var shownInMapId: String? // optional
	public var isShowInParentMap: Bool = true
//	public var isShowInList: Bool // optional
	public var isShowPin: Bool = true
	public var isOpensDetail: Bool = false

// MARK: Initialization
    public init(id: String) {
        self.id = id
        self.gameVersion = .game1
        isDummyData = true
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        gameVersion = try container.decode(GameVersion.self, forKey: .gameVersion)
        _name = try container.decode(String.self, forKey: .name)
        itemType = try container.decode(ItemType.self, forKey: .itemType)
        itemDisplayType = try container.decodeIfPresent(ItemDisplayType.self, forKey: .itemDisplayType)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        price = try container.decodeIfPresent(String.self, forKey: .price)
        relatedLinks = try container.decodeIfPresent([String].self, forKey: .relatedLinks) ?? relatedLinks
        relatedDecisionIds = try container.decodeIfPresent(
            [String].self,
            forKey: .relatedDecisionIds
        ) ?? relatedDecisionIds
        sideEffects = try container.decodeIfPresent([String].self, forKey: .sideEffects) ?? sideEffects
        relatedMissionIds = try container.decodeIfPresent(
            [String].self,
            forKey: .relatedMissionIds
        ) ?? relatedMissionIds
//        case photo
        rawEventDictionary = try container.decodeIfPresent(
            [CodableDictionary].self,
            forKey: .events
        ) ?? rawEventDictionary
        try unserializeMapLocationableData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(gameVersion, forKey: .gameVersion)
        try container.encode(_name, forKey: .name)
        try container.encode(itemType, forKey: .itemType)
        try container.encode(itemDisplayType, forKey: .itemDisplayType)
        try container.encode(description, forKey: .description)
        try container.encode(price, forKey: .price)
        try container.encode(relatedLinks, forKey: .relatedLinks)
        try container.encode(relatedDecisionIds, forKey: .relatedDecisionIds)
        try container.encode(sideEffects, forKey: .sideEffects)
        try container.encode(relatedMissionIds, forKey: .relatedMissionIds)
//        case photo
        try container.encode(rawEventDictionary, forKey: .events)
        try serializeMapLocationableData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data
extension DataItem {

	public func getInheritableEvents() -> [CodableDictionary] {
//        let events = (try? defaultManager.decoder.decode([Event].self, from: rawEventDictionary)) ?? []
//        return events.filter { $0.type.isAppliesToChildren }
        let inheritableEvents: [CodableDictionary] = rawEventDictionary.map({
            if let eventType = EventType(stringValue: $0["type"] as? String),
                eventType.isAppliesToChildren {
                return $0
            }
            return nil
        }).filter({ $0 != nil }).map({ $0! })
        return inheritableEvents
	}
}

//// MARK: SerializedDataStorable
//extension DataItem: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        return rawGeneralData
//    }
//
//}

//// MARK: SerializedDataRetrievable
//extension DataItem: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data, let id = data["id"]?.string,
//              let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0")
//        else { return nil }
//
//        self.init(id: id, gameVersion: gameVersion, data: data)
//    }
//
//    public mutating func setData(_ data: SerializableData) {
////        id = data["id"]?.string ?? id
////        gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? gameVersion
//        _name = data["name"]?.string ?? _name
//        itemType = ItemType(stringValue: data["itemType"]?.string) ?? itemType
//        itemDisplayType = ItemDisplayType(stringValue: data["itemDisplayType"]?.string)
//
//        //optional values
//        description = data["description"]?.string
//
//        inMapId = data["inMapId"]?.string
//        inMissionId = data["inMissionId"]?.string
//        if let pointData = data["mapLocationPoint"], let point = MapLocationPoint(data: pointData) {
//            mapLocationPoint = point
//            isShowInParentMap = data["isShowInParentMap"]?.bool ?? false // don't deep link if we have map location
//        } else {
//            isShowInParentMap = data["isShowInParentMap"]?.bool ?? true // deep link by default
//        }
//        isShowPin = data["isShowPin"]?.bool ?? isShowPin
//        annotationNote = data["annotationNote"]?.string
//        sortIndex = data["sortIndex"]?.int ?? 0
//
//        price = data["price"]?.string
//
//        relatedLinks = (data["relatedLinks"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        relatedDecisionIds = (data["relatedDecisionIds"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        sideEffects = (data["sideEffects"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        relatedMissionIds = (data["relatedMissionIds"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//
//        rawEventDictionary = data["events"]
//    }
//
//}

// MARK: Equatable
extension DataItem: Equatable {
	public static func == (_ lhs: DataItem, _ rhs: DataItem) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension DataItem: Hashable {
	public var hashValue: Int { return id.hashValue }
}
