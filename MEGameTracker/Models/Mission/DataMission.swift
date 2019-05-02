//
//  DataMission.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct DataMission: Codable, DataMapLocationable {

    enum CodingKeys: String, CodingKey {
        case id
        case gameVersion
        case name
        case aliases
        case missionType
        case pageTitle
        case titlePrefix
        case description
        case identicalMissionId
        case conversationRewards
        case sortIndex
        case relatedLinks
        case relatedDecisionIds
        case sideEffects
        case relatedMissionIds
        case objectivesCountToCompletion
        case events
    }

// MARK: Constants

// MARK: Properties
    public var rawData: Data? // transient
	public internal(set) var id: String
	public internal(set) var gameVersion: GameVersion
	private var _name: String = "Unknown"
	public var pageTitle: String?
	public var titlePrefix: String?
	public var aliases: [String] = []
	public var missionType: MissionType = .mission
	public var description: String?

	public private(set) var relatedLinks: [String] = []
	public internal(set) var relatedDecisionIds: [String] = [] // transient changes in Mission
	public private(set) var sideEffects: [String] = []
	public private(set) var relatedMissionIds: [String] = []
	public private(set) var photo: Photo?

	public var objectivesCountToCompletion: Int?
	public var conversationRewards = ConversationRewards()
	public var identicalMissionId: String?

	// Interface Builder
	public var isDummyData = false

// MARK: Computed Properties

	public var name: String {
		if missionType == .mission || missionType == .assignment {
			return _name
		} else {
			return "\(titlePrefix ?? missionType.titlePrefix)\(_name)"
		}
	}

    public var rawEventDictionary: [CodableDictionary] = []

// MARK: MapLocationable

	public var annotationNote: String?

	public var mapLocationType = MapLocationType.mission
	public var mapLocationPoint: MapLocationPoint?
	public var inMapId: String?
	public var inMissionId: String?
	public var sortIndex = 0

	public var isHidden = false
	public var isAvailable: Bool = true
	public var unavailabilityMessages: [String] = []

	public var searchableName: String {
		return aliases.isEmpty ? name : aliases.joined(separator: "|")
	}

//	public var linkToMapId: String?  // optional
	public var shownInMapId: String?
	public var isShowInParentMap = false
//	public var isShowInList: Bool // optional
	public var isShowPin: Bool = true
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
        gameVersion = try container.decode(GameVersion.self, forKey: .gameVersion)
        _name = try container.decode(String.self, forKey: .name)
        missionType = try container.decodeIfPresent(MissionType.self, forKey: .missionType) ?? missionType
        pageTitle = try container.decodeIfPresent(String.self, forKey: .pageTitle) ?? pageTitle
        titlePrefix = try container.decodeIfPresent(String.self, forKey: .titlePrefix) ?? titlePrefix
        aliases = try container.decodeIfPresent([String].self, forKey: .aliases) ?? aliases
        description = try container.decodeIfPresent(String.self, forKey: .description)
        identicalMissionId = try container.decodeIfPresent(
            String.self,
            forKey: .identicalMissionId
        ) ?? identicalMissionId
        conversationRewards = (try? container.decodeIfPresent(
            ConversationRewards.self,
            forKey: .conversationRewards
        )) ?? conversationRewards
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
        objectivesCountToCompletion = try container.decodeIfPresent(Int.self, forKey: .objectivesCountToCompletion)
        rawEventDictionary = (try? container.decodeIfPresent(
            [CodableDictionary].self,
            forKey: .events
        )) ?? rawEventDictionary
        try unserializeMapLocationableData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(gameVersion, forKey: .gameVersion)
        try container.encode(_name, forKey: .name)
        try container.encode(aliases, forKey: .aliases)
        try container.encode(missionType, forKey: .missionType)
        try container.encode(pageTitle, forKey: .pageTitle)
        try container.encode(titlePrefix, forKey: .titlePrefix)
        try container.encode(description, forKey: .description)
        try container.encode(identicalMissionId, forKey: .identicalMissionId)
        try container.encode(conversationRewards, forKey: .conversationRewards)
        try container.encode(sortIndex, forKey: .sortIndex)
        try container.encode(relatedLinks, forKey: .relatedLinks)
        try container.encode(relatedDecisionIds, forKey: .relatedDecisionIds)
        try container.encode(sideEffects, forKey: .sideEffects)
        try container.encode(relatedMissionIds, forKey: .relatedMissionIds)
        try container.encode(objectivesCountToCompletion, forKey: .objectivesCountToCompletion)
        try container.encode(rawEventDictionary, forKey: .events)
        try serializeMapLocationableData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data
extension DataMission {

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
//extension DataMission: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        return rawGeneralData
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension DataMission: SerializedDataRetrievable {
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
//
//        _name = data["name"]?.string ?? _name
//        aliases = (data["aliases"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        description = data["description"]?.string
//
//        missionType = MissionType(stringValue: data["missionType"]?.string) ?? missionType
//        pageTitle = data["pageTitle"]?.string
//        titlePrefix = data["titlePrefix"]?.string
//        inMissionId = data["inMissionId"]?.string
//        identicalMissionId = data["identicalMissionId"]?.string
//        isOpensDetail = data["isOpensDetail"]?.bool ?? isOpensDetail
//
//        conversationRewards = ConversationRewards(data: data["conversationRewards"]) ?? conversationRewards
//
//        inMapId = data["inMapId"]?.string
//        isShowInParentMap = data["isShowInParentMap"]?.bool ?? isShowInParentMap
//        if let pointData = data["mapLocationPoint"], let point = MapLocationPoint(data: pointData) {
//            mapLocationPoint = point
//        }
//        isShowPin = data["isShowPin"]?.bool ?? isShowPin
//        annotationNote = data["annotationNote"]?.string
//        sortIndex = data["sortIndex"]?.int ?? 0
//
//        relatedLinks = (data["relatedLinks"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        relatedDecisionIds = (data["relatedDecisionIds"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        sideEffects = (data["sideEffects"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        relatedMissionIds = (data["relatedMissionIds"]?.array ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//
//        objectivesCountToCompletion = data["objectivesCountToCompletion"]?.int
//
//        rawEventDictionary = data["events"]
//    }
//
//}

// MARK: Equatable
extension DataMission: Equatable {
	public static func == (_ lhs: DataMission, _ rhs: DataMission) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

//// MARK: Hashable
//extension DataMission: Hashable {
//    public var hashValue: Int { return id.hashValue }
//}
