//
//  Item.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

public struct Item: MapLocationable, Eventsable {

    enum CodingKeys: String, CodingKey {
        case id
        case isAcquired
    }

// MARK: Constants

// MARK: Properties
	public var generalData: DataItem

	public private(set) var id: String
	private var _annotationNote: String?

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

	// Eventsable
	private var _events: [Event]?
	public var events: [Event] {
		get { return _events ?? filterEvents(getEvents()) } // cache?
		set { _events = filterEvents(newValue) }
	}
	public var rawEventDictionary: [CodableDictionary] { return generalData.rawEventDictionary }

	public internal(set) var isAcquired = false

// MARK: Computed Properties

	public var gameVersion: GameVersion { return generalData.gameVersion }
	public var name: String { return generalData.name }
	public var description: String? { return generalData.description }
	public var itemType: ItemType { return generalData.itemType }
	public var itemDisplayType: ItemDisplayType? { return generalData.itemDisplayType }
	public var price: String? { return generalData.price }
	public var relatedLinks: [String] { return generalData.relatedLinks }
	public var sideEffects: [String] { return generalData.sideEffects }
	public var relatedMissionIds: [String] { return generalData.relatedMissionIds }

	public var hasNoAdditionalData: Bool { return generalData.hasNoAdditionalData }

	/// **Warning:** no changes are saved.
	public var relatedDecisionIds: [String] {
		// Changing the value of decisionIds does not get saved.
		// This is only for refreshing local data without a core data call.
		get { return generalData.relatedDecisionIds }
		set { generalData.relatedDecisionIds = newValue }
	}

// MARK: MapLocationable

	public var annotationNote: String? {
		get { return _annotationNote ?? generalData.annotationNote }
		set { _annotationNote = newValue }
	}

	public var mapLocationType: MapLocationType { return generalData.mapLocationType }
	public var mapLocationPoint: MapLocationPoint? {
		get { return generalData.mapLocationPoint }
		set { generalData.mapLocationPoint = newValue }
	}
	public var inMapId: String? {
		get { return generalData.inMapId }
		set {}
	}
	public var inMissionId: String? {
        get { return generalData.inMissionId }
        set {}
    }
	public var sortIndex: Int {
        get { return generalData.sortIndex }
        set {}
    }

	public var isHidden: Bool = false
	public var isAvailable: Bool {
        get {
            return generalData.isAvailable
                && events.filter({ (e: Event) in return e.isBlocking }).isEmpty
        }
        set {}
	}
	public var unavailabilityMessages: [String] {
        get {
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
        set {}
	}

	public var linkToMapId: String? { return generalData.linkToMapId }
	public var shownInMapId: String?
	public var isShowInParentMap: Bool { return generalData.isShowInParentMap }

//	public var isShowInList: Bool { return generalData.isShowInList }
	public var isShowPin: Bool { return generalData.isShowPin }
	public var isOpensDetail: Bool { return inMissionId != nil || generalData.isOpensDetail }

// MARK: Change Listeners And Change Status Flags

	/// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false
	public static var onChange = Signal<(id: String, object: Item?)>()

// MARK: Initialization

	public init(
		id: String,
		gameSequenceUuid: UUID? = App.current.game?.uuid,
		generalData: DataItem,
		events: [Event] = []
	) {
		self.id = id
		self.generalData = generalData
		self.gameSequenceUuid = gameSequenceUuid
		self.events = events
        setGeneralData()
    }

    public mutating func setGeneralData() {
        // nothing for now
    }
    public mutating func setGeneralData(_ generalData: DataItem) {
        self.generalData = generalData
        setGeneralData()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        generalData = DataItem(id: id) // faulted for now
        isAcquired = try container.decodeIfPresent(Bool.self, forKey: .isAcquired) ?? isAcquired
        try unserializeDateModifiableData(decoder: decoder)
        try unserializeGameModifyingData(decoder: decoder)
        try unserializeLocalCloudData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(isAcquired, forKey: .isAcquired)
        try serializeDateModifiableData(encoder: encoder)
        try serializeGameModifyingData(encoder: encoder)
        try serializeLocalCloudData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data
extension Item {

	/// Add game version restrictions to events.
	public func filterEvents(_ events: [Event]) -> [Event] {
		var filteredEvents: [Event] = []
		for otherGameVersion in GameVersion.all() where otherGameVersion != gameVersion {
			filteredEvents.append(Event.faulted(id: "Game\(otherGameVersion.stringValue)", type: .unavailableInGame))
		}
		filteredEvents += events.filter({ $0.gameVersion == self.gameVersion || $0.gameVersion == nil })
		return filteredEvents
	}

	/// Notesable source data
	public func getNotes(completion: @escaping (([Note]) -> Void) = { _ in }) {
		let id = self.id
		DispatchQueue.global(qos: .background).async {
			completion(Note.getAll(identifyingObject: .mission(id: id)))
		}
	}
}

// MARK: Basic Actions
extension Item {

	/// - Returns: A new note object tied to this object
	public func newNote() -> Note {
		return Note(identifyingObject: .map(id: id))
	}

}

// MARK: Data Change Actions
extension Item {

    /// Returns a copy of this Item with a set of changes applies
    public func changed(data: [String: Any?]) -> Item {
        if let isAcquired = data["isAcquired"] as? Bool {
            return changed(isAcquired: isAcquired)
        }
        return self
    }

    /// Return a copy of this Item with isSelected changed
    public func changed(
        isAcquired: Bool,
        isSave: Bool = true,
        isNotify: Bool = true,
        isCascadeChanges: EventDirection = .all
    ) -> Item {
        guard isAcquired != self.isAcquired else { return self }
        var item = self
        item.isAcquired = isAcquired
        item.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            isCascadeChanges: isCascadeChanges,
            cloudChanges: ["isAcquired": isAcquired]
        )
        return item
    }

    /// Performs common behaviors after an object change
    private mutating func changeEffects(
        isSave: Bool = true,
        isNotify: Bool = true,
        isCascadeChanges: EventDirection = .all,
        cloudChanges: [String: Any?] = [:]
    ) {
        markChanged()
        notifySaveToCloud(fields: cloudChanges)
        if isSave {
            _ = saveAnyChanges()
        }
        if isCascadeChanges != .none && !GamesDataBackup.current.isSyncing {
            applyToHierarchy(isAcquired: isAcquired, isSave: isSave, isCascadeChanges: isCascadeChanges)
        }
        if isNotify {
            Item.onChange.fire((id: self.id, object: self))
        }
    }

	mutating func applyToHierarchy(isAcquired isCompleted: Bool, isSave: Bool, isCascadeChanges: EventDirection = .all) {
		if isCascadeChanges != .down,
			let missionId = inMissionId, let parentMission = Mission.get(id: missionId) {
			let parentObjectives = parentMission.getObjectives()
			let parentObjectivesCountToCompletion = parentMission.objectivesCountToCompletion ?? parentObjectives.count
			let otherObjectivesCompletedCount = parentObjectives.filter({ $0.id != id }).filter({
				($0 as? Mission)?.isCompleted == true || ($0 as? Item)?.isAcquired == true
			}).count // don't count self
			if !isCompleted && parentMission.isCompleted
				&& parentObjectivesCountToCompletion > otherObjectivesCompletedCount {
				// uncomplete parent if any submissions are marked uncompleted
				// don't uncomplete other children
				_ = parentMission.changed(isCompleted: false, isSave: isSave, isCascadeChanges: .up)
			} else if isCompleted && !parentMission.isCompleted
				&& otherObjectivesCompletedCount + 1 >= parentObjectivesCountToCompletion {
				// complete parent if this is the last submission
				_ = parentMission.changed(isCompleted: true, isSave: isSave, isCascadeChanges: .up)
			}
		}
	}
}

// MARK: Dummy data for Interface Builder
extension Item {
	public static func getDummy(json: String? = nil) -> Item? {
		// swiftlint:disable line_length
		let json = json ?? "{\"id\":\"1\",\"gameVersion\":\"1\",\"itemType\":\"Collection\",\"itemDisplayType\":\"Loot\",\"name\":\"Salvage\",\"price\":\"100 Credits\",\"inMapId\":\"G.C1.Presidium\",}"
        if var baseItem = try? defaultManager.decoder.decode(DataItem.self, from: json.data(using: .utf8)!) {
            baseItem.isDummyData = true
            let item = Item(id: "1", generalData: baseItem)
            return item
        }
		// swiftlint:enable line_length
		return nil
	}
}

//// MARK: SerializedDataStorable
//extension Item: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        var list: [String: SerializedDataStorable?] = [:]
//        list["id"] = id
//        list["isAcquired"] = isAcquired
////        list = serializeDateModifiableData(list: list)
////        list = serializeGameModifyingData(list: list)
////        list = serializeLocalCloudData(list: list)
////        list["photo"] = photo?.getData()
//        return SerializableData.safeInit(list)
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension Item: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data, let id = data["id"]?.string,
//              let dataItem = DataItem.get(id: id),
//              let uuidString = data["gameSequenceUuid"]?.string,
//              let gameSequenceUuid = UUID(uuidString: uuidString)
//        else {
//            return nil
//        }
//
//        self.init(id: id, gameSequenceUuid: gameSequenceUuid, generalData: dataItem, data: data)
//    }
//
//    public mutating func setData(_ data: SerializableData) {
//        id = data["id"]?.string ?? id
//        if generalData.id != id {
//            generalData = DataItem.get(id: id) ?? generalData
//            _events = nil
//        }
//
////        unserializeDateModifiableData(data: data)
////        unserializeGameModifyingData(data: data)
////        unserializeLocalCloudData(data: data)
//
//        isAcquired = data["isAcquired"]?.bool ?? isAcquired
//    }
//
//}

// MARK: DateModifiable
extension Item: DateModifiable {}

// MARK: GameModifying
extension Item: GameModifying {}

// MARK: Sorting
extension Item {

	static func sort(_ first: Item, _ second: Item) -> Bool {
		if first.gameVersion != second.gameVersion {
			return first.gameVersion.stringValue < second.gameVersion.stringValue
		} else if first.isAcquired != second.isAcquired {
			return second.isAcquired // push to end
		} else if first.isAvailable != second.isAvailable {
			return first.isAvailable // push to start
		} else {
			return first.id < second.id
		}
	}
}

// MARK: Equatable
extension Item: Equatable {
	public static func == (_ lhs: Item, _ rhs: Item) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension Item: Hashable {
	public var hashValue: Int { return id.hashValue }
}
