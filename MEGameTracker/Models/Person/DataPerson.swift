//
//  DataPerson.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation

public struct DataPerson: Photographical {
// MARK: Constants

// MARK: Properties

	public fileprivate(set) var gameVersionData = SerializableData()
	internal var rawGeneralData = SerializableData() // we almost never change data row content, so just save raw data

	public fileprivate(set) var id: String
	public fileprivate(set) var gameVersion: GameVersion
	public fileprivate(set) var name: String = "Unknown"
	public fileprivate(set) var personType: PersonType = .other
	public fileprivate(set) var description: String?
	public fileprivate(set) var race: String = "Unknown"
	public fileprivate(set) var profession: String = ""
	public fileprivate(set) var organization: String?
	public fileprivate(set) var isMaleLoveInterest: Bool = false
	public fileprivate(set) var isFemaleLoveInterest: Bool = false
	public fileprivate(set) var isParamour: Bool = true
	public fileprivate(set) var voiceActor: String?
	public fileprivate(set) var relatedLinks: [String] = []
	public internal(set) var relatedDecisionIds: [String] = [] // transient changes in Person
	public fileprivate(set) var loveInterestDecisionId: String?
	public fileprivate(set) var sideEffects: [String] = []
	public fileprivate(set) var relatedMissionIds: [String] = []
	public fileprivate(set) var photo: Photo?
	public fileprivate(set) var unavailabilityMessages: [String]  = []
	public fileprivate(set) var isAvailable: Bool = true

	// Interface Builder
	public var isDummyData = false

// MARK: Computed Properties

	public var photoFileNameIdentifier: String {
		return "Person\(id)\(App.current.game?.gameVersion ?? .game1)"
	}

	public var rawEventData: SerializableData? {
		get { return rawGeneralData["events"] }
		set { rawGeneralData["events"] = newValue }
	}

// MARK: Initialization

	public init(id: String, gameVersion: GameVersion, data: SerializableData) {
		self.id = id
		self.gameVersion = gameVersion
		self.rawGeneralData = data

		rawEventData = data["events"]
		gameVersionData = data["gameVersionData"] ?? SerializableData()
		setGameVersionData()
	}

	internal mutating func setGameVersionData() {
		let gameVersionData = self.gameVersionData[gameVersion.stringValue] ?? SerializableData()
		let knownGameVersionKeys: [String] = gameVersionData.dictionary?.keys.map({ $0 }) ?? []

		name = gameVersionData["name"]?.string ?? (rawGeneralData["name"]?.string ?? name)
		personType = PersonType(stringValue: gameVersionData["personType"]?.string)
			?? (PersonType(stringValue: rawGeneralData["personType"]?.string) ?? personType)
		race = gameVersionData["race"]?.string ?? (rawGeneralData["race"]?.string ?? race)
		description = gameVersionData["description"]?.string ?? rawGeneralData["description"]?.string

		profession = gameVersionData["profession"]?.string ?? (rawGeneralData["profession"]?.string ?? "")
		organization = gameVersionData["organization"]?.string ?? rawGeneralData["organization"]?.string

		isMaleLoveInterest = gameVersionData["isMaleLoveInterest"]?.bool
			?? (rawGeneralData["isMaleLoveInterest"]?.bool ?? isMaleLoveInterest)
		isFemaleLoveInterest = gameVersionData["isFemaleLoveInterest"]?.bool
			?? (rawGeneralData["isFemaleLoveInterest"]?.bool ?? isFemaleLoveInterest)
		isParamour = gameVersionData["isParamour"]?.bool ?? (rawGeneralData["isParamour"]?.bool ?? isParamour)

		voiceActor = gameVersionData["voiceActor"]?.string ?? rawGeneralData["voiceActor"]?.string

		relatedLinks = ((gameVersionData["relatedLinks"]?.array
			?? rawGeneralData["relatedLinks"]?.array) ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
		relatedDecisionIds = ((gameVersionData["relatedDecisionIds"]?.array
			?? rawGeneralData["relatedDecisionIds"]?.array) ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
		loveInterestDecisionId = knownGameVersionKeys.contains("loveInterestDecisionId") ?
			gameVersionData["loveInterestDecisionId"]?.string : rawGeneralData["loveInterestDecisionId"]?.string
		sideEffects = ((gameVersionData["sideEffects"]?.array
			?? rawGeneralData["sideEffects"]?.array) ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })
		relatedMissionIds = ((gameVersionData["relatedMissionIds"]?.array
			?? rawGeneralData["relatedMissionIds"]?.array) ?? []).map({ $0.string }).filter({ $0 != nil }).map({ $0! })

		if let photo = Photo(filePath: gameVersionData["photo"]?.string)
			?? Photo(filePath: rawGeneralData["photo"]?.string) {
			self.photo = photo
		}
	}

}

// MARK: Retrieval Functions of Related Data
extension DataPerson {
	public func getInheritableEvents() -> [SerializableData] {
		let inheritableEvents: [SerializableData] = (rawEventData?.array ?? []).map({
			if let eventType = EventType(stringValue: $0["type"]?.string), eventType.isAppliesToChildren {
				return $0
			}
			return nil
		}).filter({ $0 != nil }).map({ $0! })
		return inheritableEvents
	}

	/// Only called on data import: can be pretty data intensive
	public func value<T>(key: String, forGame gameVersion: GameVersion) -> T? {
		let isUnavailableInGame = (rawEventData?.array ?? []).reduce(false) { (prior, data) in
			guard let id = data["id"]?.string,
				let type = EventType(stringValue: data["type"]?.string)
			else { return false }
			let e = Event.faulted(id: id, type: type)
			return prior || (e.type == .unavailableInGame ? e.isBlockingInGame(gameVersion) : false)
		}
		if !isUnavailableInGame {
			if let data = gameVersionData[gameVersion.stringValue]?[key], let value: T = data.value() {
				return value
			} else if let data = rawGeneralData[key], let value: T = data.value() {
				return value
			}
		}
		return nil
	}

	public func gameValues(key: String, defaultValue: String = "") -> String {
		var data: [String] = []
		for game in GameVersion.list() {
			data.append(value(key: key, forGame: game) ?? defaultValue)
		}
		return "|\(data.joined(separator: "|"))|"
	}
}

// MARK: Data Change Actions
extension DataPerson {
	public mutating func change(gameVersion: GameVersion) {
		self.gameVersion = gameVersion
		setGameVersionData()
	}

}

// MARK: SerializedDataStorable
extension DataPerson: SerializedDataStorable {

	public func getData() -> SerializableData {
		return rawGeneralData
	}

}

// MARK: SerializedDataRetrievable
extension DataPerson: SerializedDataRetrievable {

	public init?(data: SerializableData?) {
		guard let data = data,
			let id = data["id"]?.string
		else { return nil }
		let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? .game1

		self.init(id: id, gameVersion: gameVersion, data: data)
	}

	public mutating func setData(_ data: SerializableData) {
//		id = data["id"]?.string ?? id
//		rawEventData = data["events"] ?? rawEventData
//		if let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") {
//			self.gameVersion = gameVersion
//		}

//		for (key, value) in data.dictionary ?? [:] {
//			// does not change rawGeneralData - will not persist to database
//			gameVersionData[key] = value
//		}

//		setGameVersionData()
	}

}

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
