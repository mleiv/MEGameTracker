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
    public var rawData: Data?
	public private(set) var id: String
	public private(set) var gameVersion: GameVersion
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

	public private(set) var relatedLinks: [String] = []
	public internal(set) var relatedDecisionIds: [String] = [] // transient changes in Map
	public private(set) var sideEffects: [String] = []
	public private(set) var relatedMissionIds: [String] = []

    public private(set) var gameVersionDictionaries: [GameVersion: CodableDictionary] = [:]
    private var lastGameVersion: GameVersion?
    public private(set) var rawGameVersionData: [String: CodableDictionary] = [:]
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
        gameVersion = .game1
        name = try container.decode(String.self, forKey: .name)
        mapType = try container.decodeIfPresent(MapType.self, forKey: .mapType) ?? mapType
        description = try container.decodeIfPresent(String.self, forKey: .description)
        isMain = try container.decodeIfPresent(Bool.self, forKey: .isMain) ?? isMain
        isSplitMenu = try container.decodeIfPresent(Bool.self, forKey: .isSplitMenu) ?? isSplitMenu
        rerootBreadcrumbs = try container.decodeIfPresent(Bool.self, forKey: .rerootBreadcrumbs) ?? rerootBreadcrumbs
        isExplorable = try container.decodeIfPresent(Bool.self, forKey: .isExplorable) ?? isExplorable
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
        rawEventDictionary = try container.decodeIfPresent(
            [CodableDictionary].self,
            forKey: .events
        ) ?? rawEventDictionary
        try unserializeMapLocationableData(decoder: decoder)
        // parse and store the game version data
        let dataContainer = try decoder.singleValueContainer()
        let rawGeneralDictionary = try dataContainer.decode(CodableDictionary.self)
        let gameVersionDictionaries = try container.decodeIfPresent(
            [String: CodableDictionary].self,
            forKey: .gameVersionData
        ) ?? [:]
        for gameVersion in GameVersion.all() {
            var gameVersionDictionary = gameVersionDictionaries[gameVersion.stringValue]?.dictionary ?? [:]
            gameVersionDictionary["gameVersion"] = gameVersion.stringValue
            self.gameVersionDictionaries[gameVersion] =  CodableDictionary(
                rawGeneralDictionary.dictionary.merging(gameVersionDictionary) { (_, new) in new }
            )
        }
        rawGameVersionData = try container.decodeIfPresent(
            [String: CodableDictionary].self,
            forKey: .gameVersionData
        ) ?? rawGameVersionData
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
        try container.encode(isExplorable, forKey: .isExplorable)
        try container.encode(sortIndex, forKey: .sortIndex)
        try container.encode(relatedLinks, forKey: .relatedLinks)
        try container.encode(relatedDecisionIds, forKey: .relatedDecisionIds)
        try container.encode(sideEffects, forKey: .sideEffects)
        try container.encode(relatedMissionIds, forKey: .relatedMissionIds)
        try container.encode(image, forKey: .image)
        try container.encode(_mapSize, forKey: .referenceSize)
        try container.encode(unavailabilityMessages, forKey: .unavailabilityMessages)
        try container.encode(rawGameVersionData, forKey: .gameVersionData)
        try container.encode(rawEventDictionary, forKey: .events)
        try serializeMapLocationableData(encoder: encoder)
    }

//    // swiftlint:disable function_body_length
//    internal mutating func setGameVersionData() {
//        let gameVersionData = self.gameVersionData[gameVersion.stringValue] ?? SerializableData()
//
//        isHidden = gameVersionData["isHidden"]?.bool ?? (rawGeneralData["isHidden"]?.bool ?? false)
//
//        name = gameVersionData["name"]?.string ?? (rawGeneralData["name"]?.string ?? "Unknown")
//
//        if let gameDescription = gameVersionData["description"] { // allow nil override
//            description = gameDescription.string
//        } else {
//            description = rawGeneralData["description"]?.string
//        }
//
//        mapType = MapType(stringValue: gameVersionData["mapType"]?.string
//            ?? rawGeneralData["mapType"]?.string) ?? .location
//
//        isMain = gameVersionData["isMain"]?.bool ?? (rawGeneralData["isMain"]?.bool ?? false)
//
//        isSplitMenu = gameVersionData["isSplitMenu"]?.bool ?? (rawGeneralData["isSplitMenu"]?.bool ?? false)
//
//        if let gameInMapId = gameVersionData["inMapId"] { // allow nil override
//            inMapId = gameInMapId.string
//        } else {
//            inMapId = rawGeneralData["inMapId"]?.string
//        }
//        if let gameInMissionId = gameVersionData["inMissionId"] { // allow nil override
//            inMissionId = gameInMissionId.string
//        } else {
//            inMissionId = rawGeneralData["inMissionId"]?.string
//        }
//        if let gameLinkToMapId = gameVersionData["linkToMapId"] { // allow nil override
//            linkToMapId = gameLinkToMapId.string
//        } else {
//            linkToMapId = rawGeneralData["linkToMapId"]?.string
//        }
//
//        isShowInList = gameVersionData["isShowInList"]?.bool
//            ?? (rawGeneralData["isShowInList"]?.bool ?? true)
//
//        isOpensDetail = gameVersionData["isOpensDetail"]?.bool
//            ?? (rawGeneralData["isOpensDetail"]?.bool ?? true)
//
//        if let gameImage = gameVersionData["image"] { // allow nil override
//            image = gameImage.string
//        } else {
//            image = rawGeneralData["image"]?.string
//        }
//
//        var referenceSize = rawGeneralData["referenceSize"]?.string
//        if let gameSize = gameVersionData["referenceSize"] { // allow nil override
//            referenceSize = gameSize.string
//        }
//        setSizeData(referenceSize)
//
//        isShowPin = gameVersionData["isShowPin"]?.bool ?? (rawGeneralData["isShowPin"]?.bool ?? false)
//
//        annotationNote = gameVersionData["annotationNote"]?.string
//            ?? (rawGeneralData["annotationNote"]?.string ?? annotationNote)
//
//        if let pointData = gameVersionData["mapLocationPoint"],
//            let point = MapLocationPoint(data: pointData) {
//            self.mapLocationPoint = point
//        } else if let pointData = rawGeneralData["mapLocationPoint"],
//            let point = MapLocationPoint(data: pointData) {
//            self.mapLocationPoint = point
//        } else {
//            self.mapLocationPoint = nil
//        }
//
//        rerootBreadcrumbs = gameVersionData["rerootBreadcrumbs"]?.bool
//            ?? (rawGeneralData["rerootBreadcrumbs"]?.bool ?? rerootBreadcrumbs)
//
//        sortIndex = gameVersionData["sortIndex"]?.int ?? (rawGeneralData["sortIndex"]?.int ?? 0)
//
//        relatedLinks = ((gameVersionData["relatedLinks"]?.array
//            ?? rawGeneralData["relatedLinks"]?.array) ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        relatedDecisionIds = ((gameVersionData["relatedDecisionIds"]?.array
//            ?? rawGeneralData["relatedDecisionIds"]?.array) ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        sideEffects = ((gameVersionData["sideEffects"]?.array
//            ?? rawGeneralData["sideEffects"]?.array) ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        relatedMissionIds = ((gameVersionData["relatedMissionIds"]?.array
//            ?? rawGeneralData["relatedMissionIds"]?.array) ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//
//        isExplorable = !isHidden && !(inMapId?.isEmpty ?? true) && mapType.isExplorable
//            && (gameVersionData["isExplorable"]?.bool ?? (rawGeneralData["isExplorable"]?.bool ?? true))
//    }
//    // swiftlint:enable function_body_length
//
//    private mutating func setSizeData(_ sizeString: String?) {
//        if let sizeString = sizeString {
//            let referenceSizeBits = sizeString.components(separatedBy: "x")
//            if referenceSizeBits.count == 2 {
//                if let w = NumberFormatter().number(from: referenceSizeBits[0]),
//                    let h = NumberFormatter().number(from: referenceSizeBits[1]) {
//                    referenceSize = CGSize(width: CGFloat(w), height: CGFloat(h))
//                }
//            }
//        } else {
//            referenceSize = nil
//        }
//    }
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
        var map = self
        map.gameVersion = gameVersion
        map.lastGameVersion = gameVersion // store separately, as we need it to be null originally
        if let data = try? defaultManager.encoder.encode(gameVersionDictionaries[gameVersion] ?? [:]),
            let map = try? defaultManager.decoder.decode(DataMap.self, from: data) {
            return map
        }
        return map
    }

    public func isDifferentGameVersion(_ gameVersion: GameVersion) -> Bool {
        return gameVersion != lastGameVersion // track separately, as we need it to be null originally
    }
}

//// MARK: SerializedDataStorable
//extension DataMap: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        return rawGeneralData
//        // note: ^ this means all in-app changes must be made to Event instead, or also change this value
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension DataMap: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data,
//            let id = data["id"]?.string
//        else { return nil }
//
//        let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? .game1
//
//        self.init(id: id, gameVersion: gameVersion, data: data)
//    }
//
//    public mutating func setData(_ data: SerializableData) {
//        id = data["id"]?.string ?? id
//        rawEventDictionary = data["events"] ?? rawEventDictionary
//        if let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") {
//            self.gameVersion = gameVersion
//        }
//        for (key, value) in data.dictionary ?? [:] {
//            // does not change rawGeneralData - will not persist to database
//            gameVersionData[key] = value
//        }
//        setGameVersionData()
//    }
//
//}

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
