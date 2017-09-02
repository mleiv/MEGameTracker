//
//  Event.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/13/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public struct Event: Codable {

    enum CodingKeys: String, CodingKey {
        case id
        case gameSequenceUuid
        case type
        case isTriggered
    }

// MARK: Constants

// MARK: Properties
	public var generalData: DataEvent

	public private(set) var id: String
	public var type = EventType.unknown

	/// Not yet loaded from database.
	public var isFaulted: Bool = false

	/// (GameModifying, GameRowStorable Protocol) 
	/// This value's game identifier.
	public var gameSequenceUuid: UUID?
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
    public var pendingCloudChanges = CodableDictionary()
	/// (CloudDataStorable Protocol)  
	/// A copy of the last cloud kit record.
	public var lastRecordData: Data?

	/// transient property used for tracking purposes
	public var inMissionId: String?
	/// transient property used for tracking purposes
	public var inMapId: String?
	/// transient property used for tracking purposes
	public var inPersonId: String?
	/// transient property used for tracking purposes
	public var inItemId: String?

	public private(set) var isTriggered = false

// MARK: Computed Properties

	public var gameVersion: GameVersion? { return generalData.gameVersion }

	public var description: String? {
		if let description = generalData.description,
			let prefix = type.eventDescriptionPrefix,
			!description.isEmpty {
			if isBlocking || isBlockingAfter {
				return prefix + description
			}
			// TODO: show BlockedAfter in gray when not in play? (as a warning?)
		}
		return nil
	}

	public var isBlocking: Bool {
		switch type {
		case .blockedUntil: return !isTriggered
		case .blockedAfter: return isTriggered
		case .unavailableInGame: return isUnavailableInGame(App.current.gameVersion)
		case .requiresConfig: return isUnavailableInCurrentConfig
		default: return false
		}
	}

	public var isBlockingAfter: Bool {
		switch type {
		case .blockedAfter: return !isTriggered
		default: return false
		}
	}

	public func isBlockingInGame(_ gameVersion: GameVersion) -> Bool {
		switch type {
		case .unavailableInGame: return isUnavailableInGame(gameVersion)
		default: return gameVersion == self.generalData.gameVersion ? isBlocking : false
		}
	}

	public func isBlockingAfterInGame(_ gameVersion: GameVersion) -> Bool {
		switch type {
		case .blockedAfter: return !isTriggered && gameVersion == self.generalData.gameVersion
		default: return false
		}
	}

	private var isUnavailableInCurrentConfig: Bool {
		if type == .requiresConfig {
			switch id {
				case "Origin Earthborn": return App.current.game?.shepard?.origin != .earthborn
				case "Origin Spacer": return App.current.game?.shepard?.origin != .spacer
				case "Origin Colonist": return App.current.game?.shepard?.origin != .colonist
				default: return false
			}
		}
		return false
	}

	private func isUnavailableInGame(_ gameVersion: GameVersion) -> Bool {
		if type == .unavailableInGame {
			switch id {
				case "Game1": return gameVersion == .game1
				case "Game2": return gameVersion == .game2
				case "Game3": return gameVersion == .game3
				default: return false
			}
		}
		return false
	}

	public var isGameVersionEvent: Bool {
		// Game1, Game2, Game3
		return id[..<id.index(before: id.endIndex)] == "Game"
	}

// MARK: Change Listeners And Change Status Flags

	/// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false
//	public static var onChange = Signal<(Event)>()

// MARK: Initialization

	public init(
		id: String,
		gameSequenceUuid: UUID? = App.current.game?.uuid,
		generalData: DataEvent
	) {
		self.id = id
		self.gameSequenceUuid = gameSequenceUuid
        self.generalData = generalData  // required property, must be set here
		setGeneralData()
	}

	public mutating func setGeneralData() {
		if let dependentOn = generalData.dependentOn {
			isTriggered = dependentOn.isTriggered
		}
	}
    public mutating func setGeneralData(_ generalData: DataEvent) {
        self.generalData = generalData
        setGeneralData()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        type = (try container.decode(EventType.self, forKey: .type))
        gameSequenceUuid = try container.decode(UUID.self, forKey: .gameSequenceUuid)
        generalData = DataEvent(id: id) // faulted for now
        isTriggered = try container.decodeIfPresent(Bool.self, forKey: .isTriggered) ?? isTriggered
        try unserializeDateModifiableData(decoder: decoder)
        try unserializeGameModifyingData(decoder: decoder)
        try unserializeLocalCloudData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(gameSequenceUuid, forKey: .gameSequenceUuid)
        try container.encode(type, forKey: .type)
        try container.encode(isTriggered, forKey: .isTriggered)
        try serializeDateModifiableData(encoder: encoder)
        try serializeGameModifyingData(encoder: encoder)
        try serializeLocalCloudData(encoder: encoder)
    }
}

// MARK: Convenience Initialization
extension Event {

	/// This is a generated event - not in the db, just created locally to track availability
	private init(id: String, type: EventType) {
		self.id = id
		self.type = type
		self.isFaulted = true
        self.generalData = DataEvent(id: id) // faulted for now
		setGeneralData()
	}

	/// Returns a non-database copy. This version can't be edited.
	public static func faulted(id: String, type: EventType) -> Event {
		return Event(id: id, type: type)
	}
}

// MARK: Data Change Actions
extension Event {

	public mutating func change(
		isTriggered: Bool,
		isSave: Bool = true,
		isNotify: Bool = true,
		isCascadeChanges: EventDirection = .all
	) {
		guard !isFaulted else {
			// load real copy and act on that
			var event = Event.get(id: id)
			event?.change(
				isTriggered: isTriggered,
				isSave: isSave,
				isNotify: isNotify,
				isCascadeChanges: isCascadeChanges)
			return
		}
		guard isTriggered != self.isTriggered else { return }
		self.isTriggered = isTriggered
		markChanged()
		notifySaveToCloud(fields: ["isTriggered": isTriggered])
		if isSave {
			_ = saveAnyChanges()
		}
		if isCascadeChanges != .none  && !GamesDataBackup.current.isSyncing {
			if !generalData.isAlert {
				for action in generalData.actions {
					action.change(isTriggered: isTriggered)
				}
			}
		}
		if isNotify {
			let copySelf = self
			DispatchQueue.global(qos: .background).sync { // blocking - signals firing at same time == problems
				copySelf.notifyDataOwnersOfChange()
			}
		}
		if generalData.isAlert && isTriggered && generalData.dependentOn?.isTriggered != false { // nil or true
			let alert = Alert(title: nil, description: generalData.description ?? "")
			DispatchQueue.global(qos: .userInitiated).async {
				Alert.onSignal.fire(alert)
			}
		}
	}

	public func notifyDataOwnersOfChange() {
		// reload any changed missions not the current one
		Event.getAffectedIds(ofType: DataMission.self, relatedToEvent: self).forEach { id in
//			print("Event \(id)=\(isTriggered) affected \($0)")
			if id != inMissionId {
				Mission.onChange.fire((id: id, object: nil))
			}
		}
		// reload any changed maps not the current one
		Event.getAffectedIds(ofType: DataMap.self, relatedToEvent: self).forEach { id in
//			print("Event \(id)=\(isTriggered) affected \($0)")
			if id != inMapId {
				Map.onChange.fire((id: id, object: nil))
			}
		}
		// reload any changed persons not the current one
		Event.getAffectedIds(ofType: DataPerson.self, relatedToEvent: self).forEach { id in
//			print("Event \(id)=\(isTriggered) affected \($0)")
			if id != inPersonId {
				Person.onChange.fire((id: id, object: nil))
			}
		}
		// reload any changed items not the current one
		Event.getAffectedIds(ofType: DataItem.self, relatedToEvent: self).forEach { id in
//			print("Event \(id)=\(isTriggered) affected \($0)")
			if id != inItemId {
				Item.onChange.fire((id: id, object: nil))
			}
		}
	}
}

extension Event {

	/// Trigger all the events related to new level
	public static func triggerLevelChange(_ value: Int, for shepard: Shepard?) {
		guard value != shepard?.level, let shepard = shepard else { return }
		let events = Event.getLevels(gameVersion: shepard.gameVersion)
		for (var event) in events {
			let eventValue = event.id.stringFrom(-2)
			let level = eventValue != "00" ? Int(eventValue) : 100
			if level <= value && !event.isTriggered {
				event.change(isTriggered: true, isSave: true)
			} else if level > value && event.isTriggered {
				event.change(isTriggered: false, isSave: true)
			}
		}
		_ = shepard.changed(level: value)
	}

	/// Trigger all the events related to new paragon score
	public static func triggerParagonChange(_ value: Int, for shepard: Shepard?) {
		guard value != shepard?.paragon, let shepard = shepard else { return }
		let events = getParagons(gameVersion: shepard.gameVersion)
		for (var event) in events {
			let eventValue = event.id.stringFrom(-2)
			let paragon = eventValue != "00" ? Int(eventValue) : 100
			if paragon <= value && !event.isTriggered {
				event.change(isTriggered: true, isSave: true)
			} else if paragon > value && event.isTriggered {
				event.change(isTriggered: false, isSave: true)
			}
		}
		_ = shepard.changed(paragon: value)
	}

	/// Trigger all the events related to new renegade score
	public static func triggerRenegadeChange(_ value: Int, for shepard: Shepard?) {
		guard value != shepard?.renegade, let shepard = shepard else { return }
		let events = Event.getRenegades(gameVersion: shepard.gameVersion)
		for (var event) in events {
			let eventValue = event.id.stringFrom(-2)
			let renegade = eventValue != "00" ? Int(eventValue) : 100
			if renegade <= value && !event.isTriggered {
				event.change(isTriggered: true, isSave: true)
			} else if renegade > value && event.isTriggered {
				event.change(isTriggered: false, isSave: true)
			}
		}
		_ = shepard.changed(renegade: value)
	}
}

// MARK: Dummy data for Interface Builder
extension Event {
	public static func getDummy(json: String? = nil) -> Event? {
		// swiftlint:disable line_length
		let json = json ?? "{\"id\":\"1.1\",\"gameVersion\":\"1\",\"name\":\"Unlocked Normandy\",\"description\":\"Dummy Event Description.\"}"
        if var baseEvent = try? defaultManager.decoder.decode(DataEvent.self, from: json.data(using: .utf8)!) {
			baseEvent.isDummyData = true
			let event = Event(id: "1", generalData: baseEvent)
			return event
		}
		// swiftlint:enable line_length
		return nil
	}
}

// MARK: DateModifiable
extension Event: DateModifiable {}

// MARK: GameModifying
extension Event: GameModifying {}

// MARK: Equatable
extension Event: Equatable {
	public static func == (_ lhs: Event, _ rhs: Event) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension Event: Hashable {
	public var hashValue: Int { return id.hashValue }
}
