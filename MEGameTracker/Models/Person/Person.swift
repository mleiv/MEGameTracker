//
//  Person.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct Person: Photographical, Eventsable {
// MARK: Constants

// MARK: Properties

	public var generalData: DataPerson

	public fileprivate(set) var id: String
	public fileprivate(set) var gameVersion: GameVersion
	fileprivate var _photo: Photo?

	/// (GameModifying, GameRowStorable Protocol) 
	/// This value's game identifier.
	public var gameSequenceUuid: String?
	/// (DateModifiable Protocol)  
	/// Date when value was created.
	public var createdDate = Date()
	/// (DateModifiable Protocol)  
	/// Date when value was last changed.
	public var modifiedDate = Date()
	/// (CloudDataStorable Protocol)  
	/// Flag for whether the local object has changes not saved to the cloud.
	public var isSavedToCloud = false
	/// (CloudDataStorable Protocol)  
	/// A set of any changes to the local object since the last cloud sync.
	public var pendingCloudChanges: SerializableData?
	/// (CloudDataStorable Protocol)  
	/// A copy of the last cloud kit record.
	public var lastRecordData: Data?

	// Eventsable
	fileprivate var _events: [Event]?
	public var events: [Event] {
		get { return _events ?? getEvents() } // cache?
		set { _events = newValue }
	}
	public var rawEventData: SerializableData? { return generalData.rawEventData }

// MARK: Computed Properties

	public var name: String { return generalData.name }
	public var description: String? { return generalData.description }
	public var race: String { return generalData.race }
	public var profession: String { return generalData.profession }
	public var organization: String? { return generalData.organization }
	public var personType: PersonType { return generalData.personType }
	public var isMaleLoveInterest: Bool { return generalData.isMaleLoveInterest }
	public var isFemaleLoveInterest: Bool { return generalData.isFemaleLoveInterest }
	public var isParamour: Bool { return generalData.isParamour }
	public var voiceActor: String? { return generalData.voiceActor }
	public var relatedLinks: [String] { return generalData.relatedLinks }
	public var loveInterestDecisionId: String? { return generalData.loveInterestDecisionId }
	public var sideEffects: [String] { return generalData.sideEffects }
	public var relatedMissionIds: [String] { return generalData.relatedMissionIds }
	public var photoFileNameIdentifier: String { return generalData.photoFileNameIdentifier }
	public var photo: Photo? { return _photo ?? generalData.photo }

	public var title: String {
		return "\(race) \(profession)"
	}

	public var isLoveInterest: Bool {
		if let id = loveInterestDecisionId, let decision = Decision.get(id: id), decision.isSelected {
			return true
		}
		return false
	}

	public var isAvailableLoveInterest: Bool {
		return (App.current.game?.shepard?.gender == .male && isMaleLoveInterest)
			|| (App.current.game?.shepard?.gender == .female && isFemaleLoveInterest)
	}

	/// **Warning:** no changes are saved.
	public var relatedDecisionIds: [String] {
		// Changing the value of decisionIds does not get saved.
		// This is only for refreshing local data without a core data call.
		get { return generalData.relatedDecisionIds }
		set { generalData.relatedDecisionIds = newValue }
	}

	public var isAvailable: Bool {
		return generalData.isAvailable && events.filter({ (e: Event) in return e.isBlockingInGame(gameVersion) }).isEmpty
	}

// MARK: Change Listeners And Change Status Flags

	/// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false
	public static var onChange = Signal<(id: String, object: Person?)>()

// MARK: Initialization

	public init(
		id: String,
		gameSequenceUuid: String? = App.current.game?.uuid,
		gameVersion: GameVersion? = nil,
		generalData: DataPerson,
		events: [Event] = [],
		data: SerializableData? = nil
	) {
		self.id = id
		self.gameSequenceUuid = gameSequenceUuid
		self.gameVersion = gameVersion ?? generalData.gameVersion
		self.generalData = generalData
		self.generalData.change(gameVersion: self.gameVersion)
		self.events = events
		if let data = data {
			setData(data)
		}
	}
}

// MARK: Retrieval Functions of Related Data
extension Person {

	/// Notesable source data
	public func getNotes(completion: @escaping (([Note]) -> Void) = { _ in }) {
		let id = self.id
		DispatchQueue.global(qos: .background).async {
			completion(Note.getAll(identifyingObject: .person(id: id)))
		}
	}

	public func getRelatedMissions(completion: @escaping (([Mission]) -> Void) = {_ in }) {
		let missionIds = generalData.relatedMissionIds
		DispatchQueue.global(qos: .background).async {
			completion(Mission.getAllMissions(ids: missionIds).sorted(by: Mission.sort))
		}
	}
}

// MARK: Basic Actions
extension Person {

	/// - Returns: A new note object tied to this object
	public func newNote() -> Note {
		return Note(identifyingObject: .person(id: id))
	}

	public func isAvailableInGame(_ gameVersion: GameVersion) -> Bool {
		return generalData.isAvailable && events.filter({ e in
			return e.type == .unavailableInGame ? e.isBlockingInGame(gameVersion) : false
		}).isEmpty
	}

	public func getUnavailabilityMessages() -> [String] {
		let blockingEvents = events.filter({ (e: Event) in return e.isBlockingInGame(App.current.gameVersion) })
		if !blockingEvents.isEmpty {
			if let unavailabilityInGameMessage = blockingEvents.filter({ (e: Event) -> Bool in
					return e.type == .unavailableInGame
				}).first?.description,
				!unavailabilityInGameMessage.isEmpty {
				return generalData.unavailabilityMessages + [unavailabilityInGameMessage]
			} else {
				return generalData.unavailabilityMessages
                    + blockingEvents.map({ $0.description }).filter({ $0 != nil }).map({ $0! })
			}
		}
		return generalData.unavailabilityMessages
	}

	/// A special setter for saving a UIImage
	public mutating func savePhoto(image: UIImage, isSave: Bool = true) -> Bool {
		if let photo = Photo.create(image, object: self) {
			change(photo: photo, isSave: isSave)
			return true
		}
		return false
	}

//	public func value<T>(key: String, forGame gameVersion: GameVersion) -> T? {
//		if isAvailableInGame(gameVersion) {
//			return generalData.value(key: key, forGame: gameVersion)
//		}

//		return nil
//	}

}

// MARK: Data Change Actions
extension Person {
	public mutating func change(gameVersion: GameVersion, isSave: Bool = true, isNotify: Bool = true) {
		if gameVersion != self.gameVersion {
			self.gameVersion = gameVersion
			generalData.change(gameVersion: gameVersion)
			// nothing to save
			if isNotify {
				Person.onChange.fire((id: self.id, object: self))
			}
		}
	}
	public mutating func change(photo: Photo, isSave: Bool = true, isNotify: Bool = true) {
		if photo != self._photo {
			if let _photo = self._photo {
				_ = _photo.delete()
			}
			self._photo = photo
			markChanged()
			notifySaveToCloud(fields: ["photo": self.photo?.stringValue])
			if isSave {
				_ = saveAnyChanges()
			}
			if isNotify {
				Person.onChange.fire((id: self.id, object: self))
			}
		}
	}
}

// MARK: Dummy data for Interface Builder

extension Person {
	public static func getDummy(json: String? = nil) -> Person? {
		// swiftlint:disable line_length
		let json = json ?? "{\"id\": \"S1.Liara\",\"name\": \"Liara T\'soni\",\"description\": \"An archeologist specializing in the ancient prothean culture, Liara is the \\\"pureblood\\\" daughter of [megametracker:\\/\\/person?id=E1.Benezia]. At 106 - young for an asari - she has eschewed the typical frivolities of youth and instead pursued her research.\",\"personType\": \"Squad\",\"isMaleLoveInterest\": 1,\"isFemaleLoveInterest\": 1,\"race\": \"Asari\",\"profession\": \"Scientist\",\"organization\": null,\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game1\\/1Liara.png\",\"voiceActor\": \"Ali Hillis\",\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Liara_T%27Soni\"],\"relatedMissionIds\": [\"M1.Therum\"],\"relatedDecisionIds\": [\"D1.LoveLiara\", \"D2.LoveLiara\", \"D3.LoveLiara\"],\"loveInterestDecisionId\": \"D1.LoveLiara\",\"gameVersionData\": {\"2\": {\"personType\": \"Associate\",\"profession\": \"Information Broker\",\"description\": \"Liara was a close friend, but now she has her own agenda on Illium, turning her research skills to hunting valuable secrets, and she only briefly allies with Shepard for the Lair of the Shadow Broker (DLC) missions.\\n\\nPursuing her as a love interest in Game 2 is difficult but not impossible [Romancing Liara in Game 2|https:\\/\\/masseffect.wikia.com\\/wiki\\/Romance#Lair_of_the_Shadow_Broker].\",\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game2\\/2Liara.png\",\"loveInterestDecisionId\": \"D2.LoveLiara\"},\"3\": {\"profession\": \"Pure Biotic\",\"description\": \"After a Cerberus raid destroyed the Shadow Broker\'s lair, Liara fled with all the resources she could take with her. She is using all her Shadow Broker assets to search for a way to fight the Reapers, and she may have found it in the Mars Archives.\",\"loveInterestDecisionId\": \"D3.LoveLiara\",\"photo\": \"http:\\/\\/urdnot.com\\/megametracker\\/app\\/images\\/Game3\\/3Liara.png\"}}}"
		if var basePerson = DataPerson(serializedString: json) {
			basePerson.isDummyData = true
			let person = Person(id: "1", generalData: basePerson)
			return person
		}
		// swiftlint:enable line_length
		return nil
	}
}

// MARK: SerializedDataStorable
extension Person: SerializedDataStorable {

	public func getData() -> SerializableData {
		var list: [String: SerializedDataStorable?] = [:]
		list["id"] = id
		list["photo"] = _photo?.stringValue
		list = serializeDateModifiableData(list: list)
		list = serializeGameModifyingData(list: list)
		list = serializeLocalCloudData(list: list)
		return SerializableData.safeInit(list)
	}

}

// MARK: SerializedDataRetrievable
extension Person: SerializedDataRetrievable {

	public init?(data: SerializableData?) {
		let gameVersion = GameVersion(rawValue: data?["gameVersion"]?.string ?? "0") ?? .game1
		guard let data = data, let id = data["id"]?.string,
			  let dataPerson = DataPerson.get(id: id, gameVersion: gameVersion),
			  let gameSequenceUuid = data["gameSequenceUuid"]?.string
		else {
			return nil
		}

		self.init(id: id, gameSequenceUuid: gameSequenceUuid, gameVersion: gameVersion, generalData: dataPerson, data: data)
	}

	public mutating func setData(_ data: SerializableData) {
		id = data["id"]?.string ?? id
		if let photo = Photo(filePath: data["photo"]?.string) {
			self._photo = photo
		}
		if let gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") {
			self.gameVersion = gameVersion
			generalData.change(gameVersion: gameVersion)
//			_events = nil
		}
		if generalData.id != id {
			generalData = DataPerson.get(id: id, gameVersion: gameVersion) ?? generalData
			_events = nil
		}

		unserializeDateModifiableData(data: data)
		unserializeGameModifyingData(data: data)
		unserializeLocalCloudData(data: data)
	}

}

// MARK: DateModifiable
extension Person: DateModifiable {}

// MARK: GameModifying
extension Person: GameModifying {}

// MARK: Sorting
extension Person {
	static func sort(_ first: Person, _ second: Person) -> Bool {
		return first.name.localizedCaseInsensitiveCompare(second.name) == .orderedAscending // handle accented characters
	}
}

// MARK: Equatable
extension Person: Equatable {
	public static func == (_ lhs: Person, _ rhs: Person) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension Person: Hashable {
	public var hashValue: Int { return id.hashValue }
}
