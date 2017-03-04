//
//  Item.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 11/13/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

public struct Item: MapLocationable, Eventsable {
// MARK: Constants

// MARK: Properties
    public var generalData: DataItem

    public fileprivate(set) var id: String
    fileprivate var _annotationNote: String?
    
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
        set { generalData.inMapId = newValue }
    }
    public var inMissionId: String? { return generalData.inMissionId }
    public var sortIndex: Int { return generalData.sortIndex }
    
    public var isHidden: Bool = false
    public var isAvailable: Bool {
        return generalData.isAvailable && events.filter({ (e: Event) in return e.isBlocking }).isEmpty
    }
    public var unavailabilityMessages: [String] {
        let blockingEvents = events.filter({ (e: Event) in return e.isBlockingInGame(App.current.gameVersion) })
        if !blockingEvents.isEmpty {
            if let unavailabilityInGameMessage = blockingEvents.filter({ (e: Event) -> Bool in
                    return e.type == .unavailableInGame
                }).first?.description
                , !unavailabilityInGameMessage.isEmpty {
                return generalData.unavailabilityMessages + [unavailabilityInGameMessage]
            } else {
                return generalData.unavailabilityMessages + blockingEvents.flatMap({ $0.description })
            }
        }
        return generalData.unavailabilityMessages
    }
    
    public var linkToMapId: String? { return generalData.linkToMapId }
    public var shownInMapId: String?
    public var isShowInParentMap: Bool { return generalData.isShowInParentMap }
//    public var isShowInList: Bool { return generalData.isShowInList }
    public var isShowPin: Bool { return generalData.isShowPin }
    public var isOpensDetail: Bool { return generalData.isOpensDetail }
    
// MARK: Change Listeners And Change Status Flags
    
    /// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
    public var hasUnsavedChanges = false
    public static var onChange = Signal<(id: String, object: Item?)>()
    
// MARK: Initialization
    
    public init(
        id: String,
        gameSequenceUuid: String? = App.current.game?.uuid,
        generalData: DataItem,
        events: [Event] = [],
        data: SerializableData? = nil
    ) {
        self.id = id
        self.generalData = generalData
        self.gameSequenceUuid = gameSequenceUuid
        self.events = events
        if let data = data {
            setData(data)
        } 
    }
}

// MARK: Retrieval Functions of Related Data
extension Item {
    
    /// Add game version restrictions to events.
    public func filterEvents(_ events: [Event]) -> [Event] {
        var filteredEvents: [Event] = []
        for otherGameVersion in GameVersion.list() where otherGameVersion != gameVersion {
            filteredEvents.append(Event.faulted(id: "Game\(otherGameVersion.stringValue)", type: .unavailableInGame))
        }
        filteredEvents += events.filter({ $0.gameVersion == self.gameVersion || $0.gameVersion == nil })
        return filteredEvents
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
extension Item {
    
    /// - Returns: A new note object tied to this object
    public func newNote() -> Note {
        return Note(identifyingObject: .map(id: id))
    }
    
}

// MARK: Data Change Actions
extension Item {
    
    public mutating func change(data: SerializableData) {
        if let isAcquired = data["isAcquired"]?.bool {
            change(isAcquired: isAcquired)
        }
    }
    
    public mutating func change(
        isAcquired: Bool,
        isSave: Bool = true,
        isNotify: Bool = true,
        isCascadeChanges: EventDirection = .all
    ) {
        guard self.isAcquired != isAcquired else { return }
        self.isAcquired = isAcquired
        markChanged()
        notifySaveToCloud(fields: ["isAcquired": isAcquired])
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
            let missionId = inMissionId, var parentMission = Mission.get(id: missionId) {
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
extension Item {
    public static func getDummy(json: String? = nil) -> Item? {
        let json = json ?? "{\"id\":\"1\",\"gameVersion\":1,\"itemType\":\"Collection\",\"itemDisplayType\":\"Loot\",\"name\":\"Salvage\",\"price\":\"100 Credits\",\"inMapId\":\"G.C1.Presidium\",}"
        if var baseItem = DataItem(serializedString: json) {
            baseItem.isDummyData = true
            let item = Item(id: "1", generalData: baseItem)
            return item
        }
        return nil
    }
}

// MARK: SerializedDataStorable
extension Item: SerializedDataStorable {

    public func getData() -> SerializableData {
        var list: [String: SerializedDataStorable?] = [:]
        list["id"] = id
        list["isAcquired"] = isAcquired
        list = serializeDateModifiableData(list: list)
        list = serializeGameModifyingData(list: list)
        list = serializeLocalCloudData(list: list)
//        list["photo"] = photo?.getData()
        return SerializableData.safeInit(list)
    }
    
}

// MARK: SerializedDataRetrievable
extension Item: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data, let id = data["id"]?.string,
              let dataItem = DataItem.get(id: id),
              let gameSequenceUuid = data["gameSequenceUuid"]?.string
        else {
            return nil
        }
        
        self.init(id: id, gameSequenceUuid: gameSequenceUuid, generalData: dataItem, data: data)
    }
    
    public mutating func setData(_ data: SerializableData) {
        id = data["id"]?.string ?? id
        if generalData.id != id {
            generalData = DataItem.get(id: id) ?? generalData
            _events = nil
        }
        
        unserializeDateModifiableData(data: data)
        unserializeGameModifyingData(data: data)
        unserializeLocalCloudData(data: data)
        
        isAcquired = data["isAcquired"]?.bool ?? isAcquired
    }
    
}

// MARK: DateModifiable
extension Item: DateModifiable {}

// MARK: GameModifying
extension Item: GameModifying {}

// MARK: Sorting
extension Item {

    static func sort(_ a: Item, b: Item) -> Bool {
        if a.gameVersion != b.gameVersion {
            return a.gameVersion.stringValue < b.gameVersion.stringValue
        } else if a.isAvailable != b.isAvailable {
            return a.isAvailable
        } else {
            return a.id < b.id
        }
    }
}

//MARK: Equatable
extension Item: Equatable {
    public static func ==(a: Item, b: Item) -> Bool { // not true equality, just same db row
        return a.id == b.id
    }
}

// MARK: Hashable
extension Item: Hashable {
    public var hashValue: Int { return id.hashValue }
}
