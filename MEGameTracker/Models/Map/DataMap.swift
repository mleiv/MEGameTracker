//
//  DataMap.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct DataMap: Codable, DataMapLocationable {

    enum CodingKeys: String, CodingKey {
        case id
        case gameVersion
        case name
        case mapType
        case description
        case isMain
        case isSplitMenu
        case rerootBreadcrumbs
        case isExplorable
        case sortIndex
        case relatedLinks
        case relatedDecisionIds
        case sideEffects
        case relatedMissionIds
        case image
        case referenceSize
        case unavailabilityMessages
        case gameVersionData
        case events
    }

// MARK: Constants

// MARK: Properties
    public var rawData: Data? // transient
	public internal(set) var id: String
	public internal(set) var gameVersion: GameVersion = .game1
	public var name: String = "Unknown"
	public var mapType: MapType = .location
	public var description: String?

	public var image: String?
	private var _mapSize: MapSize = MapSize()
	public var referenceSize: CGSize? { return _mapSize.size }
	public var isMain = false
	public var isSplitMenu = false
	public var rerootBreadcrumbs: Bool = false

	public internal(set) var isExplorable: Bool = false
	private var isExplorableOverride: Bool?

	public private(set) var relatedLinks: [String] = []
	public internal(set) var relatedDecisionIds: [String] = [] // transient changes in Map
	public private(set) var sideEffects: [String] = []
	public private(set) var relatedMissionIds: [String] = []

    public private(set) var gameVersionDictionaries: [String: CodableDictionary] = [:]
    private var lastGameVersion: GameVersion?

    public var rawEventDictionary: [CodableDictionary]  = [] // leave editable for import events inheritance

	// Interface Builder
	public var isDummyData = false

// MARK: MapLocationable

	public var annotationNote: String?

	public var mapLocationType = MapLocationType.map
	public var mapLocationPoint: MapLocationPoint?
	public var inMapId: String?
	public var inMissionId: String?
	public var sortIndex = 0

	public var isHidden = false
	public var isAvailable: Bool = true
	public var unavailabilityMessages: [String] = []

//	public var searchableName: String // default
	public var linkToMapId: String?
	public var shownInMapId: String?
	public var isShowInParentMap = false
	public var isShowInList: Bool = true
	public var isShowPin: Bool = false
	public var isOpensDetail = true

// MARK: Initialization
    public init(id: String) {
        self.id = id
        self.gameVersion = .game1
        isDummyData = true
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        gameVersion = try container.decodeIfPresent(GameVersion.self, forKey: .gameVersion) ?? gameVersion
        name = try container.decode(String.self, forKey: .name)
        mapType = try container.decodeIfPresent(MapType.self, forKey: .mapType) ?? mapType
        description = try container.decodeIfPresent(String.self, forKey: .description)
        isMain = try container.decodeIfPresent(Bool.self, forKey: .isMain) ?? isMain
        isSplitMenu = try container.decodeIfPresent(Bool.self, forKey: .isSplitMenu) ?? isSplitMenu
        rerootBreadcrumbs = try container.decodeIfPresent(Bool.self, forKey: .rerootBreadcrumbs) ?? rerootBreadcrumbs
        isExplorableOverride = try container.decodeIfPresent(Bool.self, forKey: .isExplorable)
        sortIndex = try container.decodeIfPresent(Int.self, forKey: .sortIndex) ?? sortIndex
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
        image = try container.decodeIfPresent(String.self, forKey: .image)
        _mapSize = try container.decodeIfPresent(MapSize.self, forKey: .referenceSize) ?? _mapSize
        unavailabilityMessages = try container.decodeIfPresent(
            [String].self,
            forKey: .unavailabilityMessages
        ) ?? unavailabilityMessages
        gameVersionDictionaries = try container.decodeIfPresent(
            [String: CodableDictionary].self,
            forKey: .gameVersionData
        ) ?? gameVersionDictionaries
        rawEventDictionary = try container.decodeIfPresent(
            [CodableDictionary].self,
            forKey: .events
        ) ?? rawEventDictionary

        try unserializeMapLocationableData(decoder: decoder)
        isExplorable = isExplorableOverride ?? (!isHidden && !(inMapId?.isEmpty ?? true) && mapType.isExplorable)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(gameVersion, forKey: .gameVersion)
        try container.encode(name, forKey: .name)
        try container.encode(mapType, forKey: .mapType)
        try container.encode(description, forKey: .description)
        try container.encode(isMain, forKey: .isMain)
        try container.encode(isSplitMenu, forKey: .isSplitMenu)
        try container.encode(rerootBreadcrumbs, forKey: .rerootBreadcrumbs)
        try container.encode(isExplorableOverride, forKey: .isExplorable)
        try container.encode(sortIndex, forKey: .sortIndex)
        try container.encode(relatedLinks, forKey: .relatedLinks)
        try container.encode(relatedDecisionIds, forKey: .relatedDecisionIds)
        try container.encode(sideEffects, forKey: .sideEffects)
        try container.encode(relatedMissionIds, forKey: .relatedMissionIds)
        try container.encode(image, forKey: .image)
        try container.encode(_mapSize, forKey: .referenceSize)
        try container.encode(unavailabilityMessages, forKey: .unavailabilityMessages)
        try container.encode(gameVersionDictionaries, forKey: .gameVersionData)
        try container.encode(rawEventDictionary, forKey: .events)
        try serializeMapLocationableData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data
extension DataMap {

	public func getBreadcrumbs() -> [AbbreviatedMapData] {
		if isDummyData {
			return [
				AbbreviatedMapData(id: "0a", name: "Galaxy Map"), AbbreviatedMapData(id: "0b", name: "Omega Nebula")
			]
		}
		if !rerootBreadcrumbs,
			let parentMapId = self.inMapId,
			let parent = DataMap.get(id: parentMapId) {
			return parent.getBreadcrumbs() + [AbbreviatedMapData(id: parent.id, name: parent.name)]
		}
		return []
	}

	public func getCompleteBreadcrumbs() -> [AbbreviatedMapData] {
		if isDummyData {
			return [
				AbbreviatedMapData(id: "0a", name: "Galaxy Map"), AbbreviatedMapData(id: "0b", name: "Omega Nebula")
			]
		}
		if let parentMapId = self.inMapId,
			let parent = DataMap.get(id: parentMapId) {
			return parent.getCompleteBreadcrumbs() + [AbbreviatedMapData(id: parent.id, name: parent.name)]
		}
		return []
	}

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

// MARK: Data Change Actions
extension DataMap {
//    public mutating func change(gameVersion: GameVersion) {
//        self.gameVersion = gameVersion
//        setGameVersionData()
//    }

    public func changed(gameVersion: GameVersion) -> DataMap {
        guard isDifferentGameVersion(gameVersion) else { return self }
        var map = self.changed(gameVersionDictionaries[gameVersion.stringValue]?.dictionary ?? [:])
        map.gameVersion = gameVersion
        map.lastGameVersion = gameVersion
        return map
    }

    public func isDifferentGameVersion(_ gameVersion: GameVersion) -> Bool {
        return gameVersion != lastGameVersion // track separately, as we need it to be null originally
    }
}

// MARK: Equatable
extension DataMap: Equatable {
	public static func == (_ lhs: DataMap, _ rhs: DataMap) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension DataMap: Hashable {
	public var hashValue: Int { return id.hashValue }
}
