//
//  Mission.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

public struct Mission: MapLocationable, Eventsable {
// MARK: Constants

// MARK: Properties

    public var generalData: DataMission

    public fileprivate(set) var id: String
    fileprivate var _name: String?
    internal var _annotationNote: String?
    
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
        get { return _events ?? filterEvents(getEvents()) } // cache?
        set { _events = filterEvents(newValue) }
    }
    public var rawEventData: SerializableData? { return generalData.rawEventData }
    
    public internal(set) var isCompleted = false
    
// MARK: Computed Properties
    
    public var gameVersion: GameVersion { return generalData.gameVersion }
    public var name: String { return _name ?? generalData.name }
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
    public var decisionIds: [String] {
        // Changing the value of decisionIds does not get saved.
        // This is only for refreshing local data without a core data call.
        get { return generalData.decisionIds }
        set { generalData.decisionIds = newValue }
    }
    
    public var conversationRewardsDescription: String? {
        let conversationRewardsDescriptionTemplate = "%d Paragon, %d Renegade"
        let paragonPoints = conversationRewards.sum(type: .paragon)
        let renegadePoints = conversationRewards.sum(type: .renegade)
        if !conversationRewards.isEmpty {
            return String(format: conversationRewardsDescriptionTemplate, paragonPoints, renegadePoints)
        }
        return nil
    }
    
    public var selectedConversationRewards: [String] {
        return conversationRewards.selectedIds()
    }
    
    public var objectivesCountToCompletion: Int? { return generalData.objectivesCountToCompletion }
    
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
        set { generalData.inMapId = newValue }
    }
    public var inMissionId: String? { return generalData.inMissionId }
    public var sortIndex: Int { return generalData.sortIndex }
    
    public var isHidden = false
    public var isAvailable: Bool {
        return generalData.isAvailable && events.filter({ $0.isBlocking }).isEmpty
    }
    public var unavailabilityMessages: [String] {
        let blockingEvents = events.filter({ (e: Event) in return e.isBlockingInGame(App.current.gameVersion) })
        if !blockingEvents.isEmpty {
            if let unavailabilityInGameMessage = blockingEvents.filter({ (e: Event) -> Bool in
                    return e.type == .unavailableInGame
                }).first?.description,
                !unavailabilityInGameMessage.isEmpty {
                return generalData.unavailabilityMessages + [unavailabilityInGameMessage]
            } else {
                return generalData.unavailabilityMessages + blockingEvents.flatMap({ $0.description })
            }
        }
        return generalData.unavailabilityMessages
    }
    public var unavailabilityAfterMessages: [String] {
        let blockingEvents = events.filter({ (e: Event) in return e.isBlockingAfterInGame(App.current.gameVersion) })
        return blockingEvents.flatMap({ $0.description })
    }
    
//    public var searchableName: String // optional
//    public var linkToMapId: String?  // optional
    public var shownInMapId: String?
    public var isShowInParentMap: Bool { return generalData.isShowInParentMap } // optional
//    public var isShowInList: Bool // optional
    public var isShowPin: Bool { return generalData.isShowPin } // optional
    public var isOpensDetail: Bool { return generalData.isOpensDetail } // optional
    
    
// MARK: Change Listeners And Change Status Flags
    
    /// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
    public var hasUnsavedChanges = false
    public static var onChange = Signal<(id: String, object: Mission?)>()
    
// MARK: Initialization
    
    public init(
        id: String,
        gameSequenceUuid: String? = App.current.game?.uuid,
        generalData: DataMission,
        events: [Event] = [],
        data: SerializableData? = nil
    ) {
        self.id = id
        self.generalData = generalData
        self.gameSequenceUuid = gameSequenceUuid
        if let data = data {
            setData(data)
        }
    }
}
    

// MARK: Retrieval Functions of Related Data
extension Mission {
    
    /// Add game version restrictions to events.
    public func filterEvents(_ events: [Event]) -> [Event] {
        var filteredEvents: [Event] = []
        for otherGameVersion in GameVersion.list() where otherGameVersion != gameVersion {
            filteredEvents.append(Event.faulted(id: "Game\(otherGameVersion.stringValue)", type: .unavailableInGame))
        }
        //TODO: problematic database access
        filteredEvents += events.filter({ $0.gameVersion == self.gameVersion || $0.gameVersion == nil })
        return filteredEvents
    }
    
    public func getObjectives() -> [MapLocationable] {
        return Mission.getAllObjectives(underId: id)
    }
    
    public func getRelatedMissions(completion: @escaping (([Mission])->Void) = { _ in }) {
        let missionIds = generalData.relatedMissionIds
        DispatchQueue.global(qos: .background).async {
            completion(Mission.getAllMissions(ids: missionIds))
        }
    }
    
    /// Notesable source data
    public func getNotes(completion: @escaping (([Note])->Void) = { _ in }) {
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
    
    /// Applies a set of changes to this object
    public mutating func change(data: SerializableData) {
        if let name = data["name"]?.string {
            change(name: name)
        }
        if let isCompleted = data["isCompleted"]?.bool {
            change(isCompleted: isCompleted)
        }
    }
    
    public mutating func change(
        name: String?,
        isSave: Bool = true,
        isNotify: Bool = true
    ) {
        guard name != _name else { return }
        _name = name
        markChanged()
        notifySaveToCloud(fields: ["name": _name])
        if isSave {
            _ = saveAnyChanges()
        }
        if isNotify {
            Mission.onChange.fire((id: self.id, object: self))
        }
    }
    
    public mutating func change(
        conversationRewardId: String,
        isSelected: Bool,
        isSave: Bool = true,
        isNotify: Bool = true
    ) {
        if isSelected {
            generalData.conversationRewards.setSelectedId(conversationRewardId)
        } else {
            generalData.conversationRewards.unsetSelectedId(conversationRewardId)
        }
        markChanged()
        notifySaveToCloud(fields: ["selectedConversationRewards": SerializableData.safeInit(selectedConversationRewards as [SerializedDataStorable])])
        if isSave {
            _ = saveAnyChanges()
        }
        if isNotify {
            Mission.onChange.fire((id: self.id, object: self))
        }
    }
    
    public mutating func change(
        isCompleted: Bool,
        isSave: Bool = true,
        isNotify: Bool = true,
        isCascadeChanges: EventDirection = .all
    ) {
        guard self.isCompleted != isCompleted else { return }
        self.isCompleted = isCompleted
        markChanged()
        applyEventChanges(isCompleted: isCompleted)
        notifySaveToCloud(fields: ["isCompleted": isCompleted])
        if isSave {
             _ = saveAnyChanges()
        }
        if isCascadeChanges != .none && !GamesDataBackup.current.isSyncing {
            applyToHierarchy(isCompleted: isCompleted, isSave: isSave, isCascadeChanges: isCascadeChanges)
        }
        if isNotify {
            Mission.onChange.fire((id: self.id, object: self))
        }
        if !GamesDataBackup.current.isSyncing,
            let missionId = identicalMissionId,
            var identicalMission = Mission.get(id: missionId) {
            identicalMission.change(isCompleted: isCompleted)
        }
    }
    
    fileprivate mutating func applyEventChanges(isCompleted: Bool) {
        guard !GamesDataBackup.current.isSyncing else { return }
        events = events.map {
            var event = $0
            if event.type == .triggers {
                event.change(isTriggered: isCompleted, isSave: true)
            }
            return event
        }
    }
    
    fileprivate mutating func applyToHierarchy(
        isCompleted: Bool,
        isSave: Bool,
        isCascadeChanges: EventDirection = .all
    ) {
        let objectives = getObjectives()
        if isCascadeChanges != .up && isCompleted && objectivesCountToCompletion == nil {
            // don't chain uncompleted events down, and don't complete for X/Y collection missions
            for subMission in objectives.flatMap({ $0 as? Mission }) where subMission.isCompleted != isCompleted {
                // complete/uncomplete all submissions if parent was just completed/uncompleted
                var subMission = subMission
                subMission.change(isCompleted: isCompleted, isSave: isSave, isCascadeChanges: .down)
            }
            for subItem in objectives.flatMap({ $0 as? Item }) where subItem.isAcquired != isCompleted {
                // complete/uncomplete all items if parent was just completed/uncompleted
                var subItem = subItem
                subItem.change(isAcquired: isCompleted, isSave: isSave, isCascadeChanges: .down)
            }
        }
        if isCascadeChanges != .down, var parentMission = self.parentMission {
            let parentObjectives = parentMission.getObjectives()
            let parentObjectivesCountToCompletion = parentMission.objectivesCountToCompletion ?? parentObjectives.count
            let otherObjectivesCompletedCount = parentObjectives.filter({ $0.id != id }).filter(
                { ($0 as? Mission)?.isCompleted == true || ($0 as? Item)?.isAcquired == true }
            ).count // don't count self
            if !isCompleted && parentMission.isCompleted
                && parentObjectivesCountToCompletion > otherObjectivesCompletedCount {
                // uncomplete parent if any submissions are marked uncompleted
                parentMission.change(isCompleted: false, isSave: isSave, isCascadeChanges: .up) // don't uncomplete other children
            } else if isCompleted && !parentMission.isCompleted
                && otherObjectivesCompletedCount + 1 >= parentObjectivesCountToCompletion {
                // complete parent if this is the last submission
                parentMission.change(isCompleted: true, isSave: isSave, isCascadeChanges: .up)
            }
        }
    }
}

// MARK: Dummy data for Interface Builder

extension Mission {
    public static func getDummy(json: String? = nil) -> Mission? {
        let json = json ?? "{\"id\": \"1.1\",\"gameVersion\": \"2\",\"missionType\": \"Objective\",\"name\": \"Head to the Camp\",\"isAvailable\": true,\"description\": \"Locate the dig site on the map and head towards it.\",\"inMapId\": null,\"inMissionId\": \"1\",\"conversationRewards\": [{\"exclusiveSet\": [{\"type\": \"Paragon\",\"value\": 2,\"message\": \"After Jenkins dies: \\\"He deserves a burial.\\\"\" }, {\"type\": \"Renegade\",\"value\": 2,\"message\": \"After Jenkins dies: \\\"Forget about him.\\\"\"}]}]}"
        if var baseMission = DataMission(serializedString: json) {
            baseMission.isDummyData = true
            let mission = Mission(id: "1", generalData: baseMission)
            return mission
        }
        return nil
    }
}

// MARK: SerializedDataStorable
extension Mission: SerializedDataStorable {

    public func getData() -> SerializableData {
        var list: [String: SerializedDataStorable?] = [:]
        list["id"] = id
        list["name"] = _name
        list["isCompleted"] = isCompleted
        list["selectedConversationRewards"] = SerializableData.safeInit(selectedConversationRewards as [SerializedDataStorable])
        list = serializeDateModifiableData(list: list)
        list = serializeGameModifyingData(list: list)
        list = serializeLocalCloudData(list: list)
        return SerializableData.safeInit(list)
    }
    
}

// MARK: SerializedDataRetrievable
extension Mission: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data, let id = data["id"]?.string,
              let dataMission = DataMission.get(id: id),
              let gameSequenceUuid = data["gameSequenceUuid"]?.string
        else {
            return nil
        }
        
        self.init(id: id, gameSequenceUuid: gameSequenceUuid, generalData: dataMission, data: data)
    }
    
    public mutating func setData(_ data: SerializableData) {
        id = data["id"]?.string ?? id
        if generalData.id != id {
            generalData = DataMission.get(id: id) ?? generalData
            _events = nil
        }
        
        _name = data["name"]?.string
        
        let _selectedConversationRewards = (data["selectedConversationRewards"]?.array ?? []).flatMap({ $0.string })
        generalData.conversationRewards.setSelectedIds(_selectedConversationRewards)
        
        unserializeDateModifiableData(data: data)
        unserializeGameModifyingData(data: data)
        unserializeLocalCloudData(data: data)
        
        isCompleted = data["isCompleted"]?.bool ?? isCompleted
    }
    
}

// MARK: DateModifiable
extension Mission: DateModifiable {}

// MARK: GameModifying
extension Mission: GameModifying {}

// MARK: Sorting
extension Mission {
    
    /// Sorts by availability, then by sortIndex, then by name
    static func sort(_ a: Mission, b: Mission) -> Bool {
        if a.gameVersion != b.gameVersion {
            return a.gameVersion.intValue < b.gameVersion.intValue
        } else if a.isCompleted != b.isCompleted {
            return b.isCompleted // push to end
        } else if a.isAvailable != b.isAvailable {
            return a.isAvailable // push to start
        } else if a.missionType != b.missionType {
            return a.missionType.intValue < b.missionType.intValue
        } else if a.sortIndex != b.sortIndex {
            return a.sortIndex < b.sortIndex
        } else {
            return a.id < b.id
        }
    }
}

// MARK: Equatable
extension Mission: Equatable {}

public func ==(a: Mission, b: Mission) -> Bool { // not true equality, just same db row
    return a.id == b.id
}
