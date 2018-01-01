//
//  DataPerson.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation

public struct DataPerson: Codable, Photographical {

    enum CodingKeys: String, CodingKey {
        case id
        case gameVersion
        case name
        case personType
        case description
        case race
        case profession
        case organization
        case isMaleLoveInterest
        case isFemaleLoveInterest
        case loveInterestDecisionId
        case isParamour
        case voiceActor
//        case sortIndex
        case relatedLinks
        case relatedDecisionIds
        case sideEffects
        case relatedMissionIds
        case photo
        case unavailabilityMessages
        case gameVersionData
        case events
    }
// MARK: Constants

// MARK: Properties
    public var rawData: Data? // transient
	public internal(set) var id: String
	public internal(set) var gameVersion: GameVersion = .game1
	public private(set) var name: String = "Unknown"
	public private(set) var personType: PersonType = .other
	public private(set) var description: String?
	public private(set) var race: String = "Unknown"
	public private(set) var profession: String = ""
	public private(set) var organization: String?
	public private(set) var isMaleLoveInterest: Bool = false
	public private(set) var isFemaleLoveInterest: Bool = false
	public private(set) var isParamour: Bool = true
    public private(set) var photo: Photo?
	public private(set) var voiceActor: String?
	public private(set) var relatedLinks: [String] = []
	public internal(set) var relatedDecisionIds: [String] = [] // transient changes in Person
	public private(set) var loveInterestDecisionId: String?
	public private(set) var sideEffects: [String] = []
	public private(set) var relatedMissionIds: [String] = []
	public private(set) var unavailabilityMessages: [String]  = []
	public let isAvailable: Bool = true

    public private(set) var gameVersionDictionaries: [String: CodableDictionary] = [:]
    private var lastGameVersion: GameVersion?

    public private(set) var rawEventDictionary: [CodableDictionary]  = []

	// Interface Builder
	public var isDummyData = false

// MARK: Computed Properties

	public var photoFileNameIdentifier: String {
		return "Person\(id)\(App.current.game?.gameVersion ?? .game1)"
	}

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
        personType = try container.decode(PersonType.self, forKey: .personType)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        race = try container.decodeIfPresent(String.self, forKey: .race) ?? race
        profession = try container.decodeIfPresent(String.self, forKey: .profession) ?? profession
        organization = try container.decodeIfPresent(String.self, forKey: .organization) ?? organization
        loveInterestDecisionId = try container.decodeIfPresent(
            String.self,
            forKey: .loveInterestDecisionId
        ) ?? loveInterestDecisionId
        isMaleLoveInterest = try container.decodeIfPresent(
            Bool.self,
            forKey: .isMaleLoveInterest
        ) ?? isMaleLoveInterest
        isFemaleLoveInterest = try container.decodeIfPresent(
            Bool.self,
            forKey: .isFemaleLoveInterest
        ) ?? isFemaleLoveInterest
        isParamour = try container.decodeIfPresent(Bool.self, forKey: .isParamour) ?? isParamour
        if let filePath = try container.decodeIfPresent(String.self, forKey: .photo),
            let photo = Photo(filePath: filePath) {
            self.photo = photo
        }
        voiceActor = try container.decodeIfPresent(String.self, forKey: .voiceActor) ?? voiceActor
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
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(personType, forKey: .personType)
        try container.encode(description, forKey: .description)
        try container.encode(race, forKey: .race)
        try container.encode(profession, forKey: .profession)
        try container.encode(organization, forKey: .organization)
        try container.encode(loveInterestDecisionId, forKey: .loveInterestDecisionId)
        try container.encode(isMaleLoveInterest, forKey: .isMaleLoveInterest)
        try container.encode(isFemaleLoveInterest, forKey: .isFemaleLoveInterest)
        try container.encode(photo?.filePath, forKey: .photo)
        try container.encode(isParamour, forKey: .isParamour)
        try container.encode(voiceActor, forKey: .voiceActor)
        try container.encode(relatedLinks, forKey: .relatedLinks)
        try container.encode(relatedDecisionIds, forKey: .relatedDecisionIds)
        try container.encode(sideEffects, forKey: .sideEffects)
        try container.encode(relatedMissionIds, forKey: .relatedMissionIds)
        try container.encode(unavailabilityMessages, forKey: .unavailabilityMessages)
        try container.encode(gameVersionDictionaries, forKey: .gameVersionData)
        try container.encode(rawEventDictionary, forKey: .events)
    }
}

// MARK: Retrieval Functions of Related Data
extension DataPerson {

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

	/// Only called on data import: can be pretty data intensive
	public func value(key: String, forGame gameVersion: GameVersion) -> String? {
		let isUnavailableInGame = rawEventDictionary.reduce(false) { (prior, data) in
            guard let id = data["id"] as? String,
                let type = EventType(stringValue: data["type"] as? String)
            else { return false }
            let e = Event.faulted(id: id, type: type)
            return prior || (e.type == .unavailableInGame ? e.isBlockingInGame(gameVersion) : false)
		}
		if !isUnavailableInGame {
            guard let values = gameVersionDictionaries[gameVersion.stringValue],
                values.dictionary.keys.contains(key)
            else {
                if let value = valueForKey(key) {
                    if let boolValue = value as? Bool {
                        return (boolValue ? "1" : "0")
                    } else {
                        return "\(value)"
                    }
                }
                return nil
            }
            if let boolValue = values[key] as? Bool {
                return (boolValue ? "1" : "0")
            } else if let value = values[key] {
                return "\(value)"
			}
		}
		return nil
	}

    public func gameValues(key: String, defaultValue: String = "") -> String {
        var data: [String] = []
        for game in GameVersion.all() {
            data.append(value(key: key, forGame: game) ?? defaultValue)
        }
        return "|\(data.joined(separator: "|"))|".lowercased()
    }

    private func valueForKey(_ key: String) -> Any? {
        let m = Mirror(reflecting: self)
        for child in m.children {
            if child.label == key { return child.value }
        }
        return nil
    }
}

// MARK: Data Change Actions
extension DataPerson {
    public func changed(gameVersion: GameVersion) -> DataPerson {
        guard isDifferentGameVersion(gameVersion) else { return self }
        var person = self.changed(gameVersionDictionaries[gameVersion.stringValue]?.dictionary ?? [:])
        person.gameVersion = gameVersion
        person.lastGameVersion = gameVersion
        return person
    }

    public func isDifferentGameVersion(_ gameVersion: GameVersion) -> Bool {
        return gameVersion != lastGameVersion // track separately, as we need it to be null originally
    }
}

//// MARK: SerializedDataStorable
//extension DataPerson: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        return rawGeneralDictionary
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension DataPerson: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data,
//            let id = data["id"]?.string
//        else { return nil }
//        let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? .game1
//
//        self.init(id: id, gameVersion: gameVersion, data: data)
//    }
//
//    public mutating func setData(_ data: SerializableData) {
////        id = data["id"]?.string ?? id
////        rawEventDictionary = data["events"] ?? rawEventDictionary
////        if let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") {
////            self.gameVersion = gameVersion
////        }
//
////        for (key, value) in data.dictionary ?? [:] {
////            // does not change rawGeneralDictionary - will not persist to database
////            gameVersionDictionary[key] = value
////        }
//
////        setGameVersionData()
//    }
//
//}

// MARK: Equatable
extension DataPerson: Equatable {
	public static func == (_ lhs: DataPerson, _ rhs: DataPerson) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension DataPerson: Hashable {
	public var hashValue: Int { return id.hashValue }
}
