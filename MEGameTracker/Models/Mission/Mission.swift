//
//  Mission.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

// swiftlint:disable file_length

public struct Mission: Codable, MapLocationable, Eventsable {

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case isCompleted
        case selectedConversationRewards
    }

// MARK: Constants
	let rewardsSummaryTemplate = "%d Paragon, %d Renegade"
	let game3RewardsSummaryTemplate = "%d Paragon, %d Renegade, %d Reputation"

// MARK: Properties
    public var rawData: Data? // transient
	public var generalData: DataMission

	public private(set) var id: String
	private var overrideName: String?
	internal var overrideAnnotationNote: String?

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

	public internal(set) var isCompleted = false

// MARK: Computed Properties

	public var gameVersion: GameVersion { return generalData.gameVersion }
	public var name: String { return overrideName ?? generalData.name }
	public var aliases: [String] { return generalData.aliases }
	public var description: String? { return generalData.description }
	public var missionType: MissionType { return generalData.missionType }
	public var identicalMissionId: String? { return generalData.identicalMissionId }
	public var relatedLinks: [String] { return generalData.relatedLinks }
	public var sideEffects: [String] { return generalData.sideEffects }
	public var relatedMissionIds: [String] { return generalData.relatedMissionIds }
	public var conversationRewards: ConversationRewards { return generalData.conversationRewards }

	public var pageTitle: String? {
		return generalData.pageTitle
	}

	public var parentMission: Mission? {
		if let id = inMissionId {
			return Mission.get(id: id)
		}
		return nil
	}

	/// **Warning:** no changes are saved.
	public var relatedDecisionIds: [String] {
		// Changing the value of decisionIds does not get saved.
		// This is only for refreshing local data without a core data call.
		get { return generalData.relatedDecisionIds }
		set { generalData.relatedDecisionIds = newValue }
	}

	public var conversationRewardsDescription: String? {
		let paragonPoints = conversationRewards.sum(type: .paragon)
		let renegadePoints = conversationRewards.sum(type: .renegade)
		let neutralPoints = gameVersion == .game3 ? conversationRewards.sum(type: .neutral) : 0
		if !conversationRewards.isEmpty {
			if neutralPoints > 0 {
				return String(format: game3RewardsSummaryTemplate, paragonPoints, renegadePoints, neutralPoints)
			} else {
				return String(format: rewardsSummaryTemplate, paragonPoints, renegadePoints)
			}
		}
		return nil
	}

	public var selectedConversationRewards: [String] {
		return conversationRewards.selectedIds()
	}
	private var tempSelectedConversationRewards: [String]?

	public var objectivesCountToCompletion: Int? { return generalData.objectivesCountToCompletion }

// MARK: MapLocationable

	public var annotationNote: String? {
		get { return overrideAnnotationNote ?? generalData.annotationNote }
		set { overrideAnnotationNote = newValue }
	}

	public var mapLocationType: MapLocationType { return generalData.mapLocationType }
	public var mapLocationPoint: MapLocationPoint? {
		get { return generalData.mapLocationPoint }
		set { generalData.mapLocationPoint = newValue }
	}
	public var inMapId: String? {
		get { return generalData.inMapId }
		set { generalData.inMapId = newValue }
	}
	public var inMissionId: String? {
        get { return generalData.inMissionId }
        set { generalData.inMissionId = newValue }
    }
	public var sortIndex: Int {
        get { return generalData.sortIndex }
        set {}
    }

	public var isHidden = false
	public var isAvailable: Bool {
        get {
            return generalData.isAvailable && events.filter({ $0.isBlocking }).isEmpty
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
	public var unavailabilityAfterMessages: [String] {
		let blockingEvents = events.filter({ (e: Event) in return e.isBlockingAfterInGame(App.current.gameVersion) })
		return blockingEvents.map({ $0.description }).filter({ $0 != nil }).map({ $0! })
	}

//	public var searchableName: String // optional
//	public var linkToMapId: String?  // optional
	public var shownInMapId: String?
	public var isShowInParentMap: Bool { return generalData.isShowInParentMap } // optional
//	public var isShowInList: Bool // optional
	public var isShowPin: Bool { return generalData.isShowPin } // optional
	public var isOpensDetail: Bool { return generalData.isOpensDetail } // optional

// MARK: Change Listeners And Change Status Flags

	/// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
	public var hasUnsavedChanges = false
	public static var onChange = Signal<(id: String, object: Mission?)>()

// MARK: Initialization

	public init(
		id: String,
		gameSequenceUuid: UUID? = App.current.game?.uuid,
		generalData: DataMission,
		events: [Event] = []
	) {
		self.id = id
		self.gameSequenceUuid = gameSequenceUuid
        self.generalData = generalData
        self.events = events
        setGeneralData()
    }

    public mutating func setGeneralData() {
        if let list = tempSelectedConversationRewards {
            generalData.conversationRewards.setSelectedIds(list)
            tempSelectedConversationRewards = []
        }
    }
    public mutating func setGeneralData(_ generalData: DataMission) {
        self.generalData = generalData
        setGeneralData()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        generalData = DataMission(id: id) // faulted for now
        overrideName = try container.decodeIfPresent(String.self, forKey: .name)
        isCompleted = try container.decodeIfPresent(Bool.self, forKey: .isCompleted) ?? isCompleted
        tempSelectedConversationRewards = try container.decodeIfPresent(
            [String].self,
            forKey: .selectedConversationRewards
        )
        try unserializeDateModifiableData(decoder: decoder)
        try unserializeGameModifyingData(decoder: decoder)
        try unserializeLocalCloudData(decoder: decoder)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(overrideName, forKey: .name)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(selectedConversationRewards, forKey: .selectedConversationRewards)
        try serializeDateModifiableData(encoder: encoder)
        try serializeGameModifyingData(encoder: encoder)
        try serializeLocalCloudData(encoder: encoder)
    }
}

// MARK: Retrieval Functions of Related Data
extension Mission {

    /// Add game version restrictions to events.
    public func filterEvents(_ events: [Event]) -> [Event] {
        var filteredEvents: [Event] = []
        for otherGameVersion in GameVersion.all() where otherGameVersion != gameVersion {
            filteredEvents.append(Event.faulted(id: "Game\(otherGameVersion.stringValue)", type: .unavailableInGame))
        }
        filteredEvents += events.filter({ $0.gameVersion == self.gameVersion || $0.gameVersion == nil })
        return filteredEvents
    }

	public func getObjectives() -> [MapLocationable] {
		return Mission.getAllObjectives(underId: id).sorted(by: MapLocation.sort)
	}

	public func getRelatedMissions(completion: @escaping (([Mission]) -> Void) = { _ in }) {
		let missionIds = generalData.relatedMissionIds
		DispatchQueue.global(qos: .background).async {
			completion(Mission.getAllMissions(ids: missionIds).sorted(by: Mission.sort))
		}
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
extension Mission {

	/// - Returns: A new note object tied to this object
	public func newNote() -> Note {
		return Note(identifyingObject: .mission(id: id))
	}

}

// MARK: Data Change Actions
extension Mission {

    /// Returns a copy of this Mission with a set of changes applies
    public func changed(fromActionData data: [String: Any?]) -> Mission {
        if let name = data["name"] as? String {
            return changed(name: name)
        } else if let isCompleted = data["isCompleted"] as? Bool {
            return changed(isCompleted: isCompleted)
        }
        return self
    }

    /// Return a copy of this Mission with isCompleted changed
    public func changed(
        isCompleted: Bool,
        isSave: Bool = true,
        isNotify: Bool = true,
        isCascadeChanges: EventDirection = .all
    ) -> Mission {
        guard self.isCompleted != isCompleted else { return self }
        var mission = self
        mission.isCompleted = isCompleted
        mission.applyEventChanges(isCompleted: isCompleted)
        mission.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["isCompleted": isCompleted]
        )
        if isCascadeChanges != .none && !GamesDataBackup.current.isSyncing {
            mission.applyToHierarchy(
                isCompleted: isCompleted,
                isSave: isSave,
                isCascadeChanges: isCascadeChanges
            )
        }
        // copy changes to any identical missions
        if !GamesDataBackup.current.isSyncing,
            let missionId = identicalMissionId {
            _ = Mission.get(id: missionId)?.changed(isCompleted: isCompleted)
        }
        return mission
    }

    /// Return a copy of this Mission with name changed
	public func changed(
		name: String?,
		isSave: Bool = true,
		isNotify: Bool = true
	) -> Mission {
		guard name != overrideName else { return self }
        var mission = self
		mission.overrideName = name
        mission.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: ["name": name]
        )
        return mission
	}

    /// Return a copy of this Mission with conversationRewardId changed
	public func changed(
		conversationRewardId: String,
		isSelected: Bool,
		isSave: Bool = true,
		isNotify: Bool = true
	) -> Mission {
        var mission = self
		if isSelected {
			mission.generalData.conversationRewards.setSelectedId(conversationRewardId)
		} else {
			mission.generalData.conversationRewards.unsetSelectedId(conversationRewardId)
		}
        mission.changeEffects(
            isSave: isSave,
            isNotify: isNotify,
            cloudChanges: [
                "selectedConversationRewards": selectedConversationRewards
            ]
        )
        return mission
    }

    /// Performs common behaviors after an object change
    private mutating func changeEffects(
        isSave: Bool = true,
        isNotify: Bool = true,
        cloudChanges: [String: Any?] = [:]
    ) {
        markChanged()
        notifySaveToCloud(fields: cloudChanges)
        if isSave {
             _ = saveAnyChanges()
        }
        if isNotify {
            Mission.onChange.fire((id: self.id, object: self))
        }
    }

	private mutating func applyEventChanges(isCompleted: Bool) {
		guard !GamesDataBackup.current.isSyncing else { return }
		events = events.map {
			return $0.type == .triggers
                ? $0.changed(isTriggered: isCompleted, isSave: true) ?? $0
                : $0
		}
	}

	private mutating func applyToHierarchy(
		isCompleted: Bool,
		isSave: Bool,
		isCascadeChanges: EventDirection = .all
	) {
		let objectives = getObjectives()
		if isCascadeChanges != .up && isCompleted && objectivesCountToCompletion == nil {
			// don't chain uncompleted events down, and don't complete for X/Y collection missions
			for subMission in objectives.map({ $0 as? Mission }).filter({ $0 != nil }).map({ $0! })
                where subMission.isCompleted != isCompleted {
				// complete/uncomplete all submissions if parent was just completed/uncompleted
				_ = subMission.changed(isCompleted: isCompleted, isSave: isSave, isCascadeChanges: .down)
			}
			for subItem in objectives.map({ $0 as? Item }).filter({ $0 != nil }).map({ $0! })
                where subItem.isAcquired != isCompleted {
				// complete/uncomplete all items if parent was just completed/uncompleted
				_ = subItem.changed(isAcquired: isCompleted, isSave: isSave, isCascadeChanges: .down)
			}
		}
		if isCascadeChanges != .down, let parentMission = self.parentMission {
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

extension Mission {
	public static func getDummy(json: String? = nil) -> Mission? {
		// swiftlint:disable line_length
		let json = json ?? "{\"id\": \"1.1\",\"gameVersion\": \"2\",\"missionType\": \"Objective\",\"name\": \"Head to the Camp\",\"isAvailable\": true,\"description\": \"Locate the dig site on the map and head towards it.\",\"inMapId\": null,\"inMissionId\": \"1\",\"conversationRewards\": [{\"exclusiveSet\": [{\"type\": \"Paragon\",\"value\": 2,\"message\": \"After Jenkins dies: \\\"He deserves a burial.\\\"\" }, {\"type\": \"Renegade\",\"value\": 2,\"message\": \"After Jenkins dies: \\\"Forget about him.\\\"\"}]}]}"
        if var baseMission = try? defaultManager.decoder.decode(DataMission.self, from: json.data(using: .utf8)!) {
            baseMission.isDummyData = true
            let mission = Mission(id: "1", generalData: baseMission)
            return mission
        }
		// swiftlint:enable line_length
		return nil
	}
}

//// MARK: SerializedDataStorable
//extension Mission: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        var list: [String: SerializedDataStorable?] = [:]
//        list["id"] = id
//        list["name"] = overrideName
//        list["isCompleted"] = isCompleted
//        list["selectedConversationRewards"] = SerializableData.safeInit(
//            selectedConversationRewards as [SerializedDataStorable]
//        )
////        list = serializeDateModifiableData(list: list)
////        list = serializeGameModifyingData(list: list)
////        list = serializeLocalCloudData(list: list)
//        return SerializableData.safeInit(list)
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension Mission: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data, let id = data["id"]?.string,
//              let dataMission = DataMission.get(id: id),
//              let uuidString = data["gameSequenceUuid"]?.string,
//              let gameSequenceUuid = UUID(uuidString: uuidString)
//        else {
//            return nil
//        }
//
//        self.init(id: id, gameSequenceUuid: gameSequenceUuid, generalData: dataMission, data: data)
//    }
//
//    public mutating func setData(_ data: SerializableData) {
//        id = data["id"]?.string ?? id
//        if generalData.id != id {
//            generalData = DataMission.get(id: id) ?? generalData
//            _events = nil
//        }
//
//        overrideName = data["name"]?.string
//
//        let _selectedConversationRewards = (data["selectedConversationRewards"]?.array ?? [])
//            .map({ $0.string }).filter({ $0 != nil }).map({ $0! })
//        generalData.conversationRewards.setSelectedIds(_selectedConversationRewards)
//
////        unserializeDateModifiableData(data: data)
////        unserializeGameModifyingData(data: data)
////        unserializeLocalCloudData(data: data)
//
//        isCompleted = data["isCompleted"]?.bool ?? isCompleted
//    }
//
//}

// MARK: DateModifiable
extension Mission: DateModifiable {}

// MARK: GameModifying
extension Mission: GameModifying {}

// MARK: Sorting
extension Mission {

	/// Sorts by availability, then by sortIndex, then by name
	static func sort(_ first: Mission, _ second: Mission) -> Bool {
		if first.gameVersion != second.gameVersion {
			return first.gameVersion.intValue < second.gameVersion.intValue
		} else if first.isCompleted != second.isCompleted {
			return second.isCompleted // push to end
		} else if first.isAvailable != second.isAvailable {
			return first.isAvailable // push to start
		} else if first.missionType != second.missionType {
			return first.missionType.intValue < second.missionType.intValue
		} else if first.sortIndex != second.sortIndex {
			return first.sortIndex < second.sortIndex
		} else {
			return first.id < second.id
		}
	}
}

// MARK: Equatable
extension Mission: Equatable {
	public static func == (_ lhs: Mission, _ rhs: Mission) -> Bool { // not true equality, just same db row
		return lhs.id == rhs.id
	}
}

// MARK: Hashable
extension Mission: Hashable {
	public var hashValue: Int { return id.hashValue }
}
// swiftlint:enable file_length
