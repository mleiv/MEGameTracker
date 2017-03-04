//
//  Event.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/13/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public struct Event {
// MARK: Constants

// MARK: Properties
    public var generalData: DataEvent
    
    public fileprivate(set) var id: String
    public var type = EventType.unknown
    
    /// Not yet loaded from database.
    public var isFaulted: Bool
    
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
    
    /// transient property used for tracking purposes
    public var inMissionId: String?
    /// transient property used for tracking purposes
    public var inMapId: String?
    /// transient property used for tracking purposes
    public var inPersonId: String?
    /// transient property used for tracking purposes
    public var inItemId: String?
    
    public internal(set) var isTriggered = false
    
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
    
    fileprivate var isUnavailableInCurrentConfig: Bool {
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
    
    fileprivate func isUnavailableInGame(_ gameVersion: GameVersion) -> Bool {
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
        return id.substring(to: id.index(before: id.endIndex)) == "Game"
    }
    
// MARK: Change Listeners And Change Status Flags
    
    /// (DateModifiable, GameRowStorable) Flag to indicate that there are changes pending a core data sync.
    public var hasUnsavedChanges = false
//    public static var onChange = Signal<(Event)>()
    
// MARK: Initialization
    
    public init(
        id: String,
        gameSequenceUuid: String? = App.current.game?.uuid,
        generalData: DataEvent,
        data: SerializableData? = nil
    ) {
        self.id = id
        self.generalData = generalData
        self.gameSequenceUuid = gameSequenceUuid
        self.isFaulted = false
        if let data = data {
            setData(data)
        } else {
            setGeneralData()
        }
    }
    
    public mutating func setGeneralData() {
        if let dependentOn = generalData.dependentOn {
            isTriggered = dependentOn.isTriggered
        }
    }
    
}

// MARK: Convenience Initialization
extension Event {
    
    /// This is a generated event - not in the db, just created locally to track availability
    private init(id: String, type: EventType) {
        self.id = id
        self.type = type
        self.generalData = DataEvent(id: id)
        self.isFaulted = true
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
        if generalData.isAlert && isTriggered && generalData.dependentOn?.isTriggered != false { // nil or true
            let alert = Alert(title: nil, description: generalData.description ?? "")
            Delay.bySeconds(0, { Alert.onSignal.fire(alert) })
        }
        if isNotify {
            self.notifyDataOwnersOfChange()
//            Event.onChange.fire(self)
        }
    }
    
    public func notifyDataOwnersOfChange() {
        // reload any changed missions not the current one
        Event.getAffectedIds(ofType: DataMission.self, relatedToEvent: self).forEach {
//            print("Event \(id)=\(isTriggered) affected \($0)")
            if $0 != inMissionId {
                Mission.onChange.fire((id: $0, object: nil))
            }
        }
        // reload any changed maps not the current one
        Event.getAffectedIds(ofType: DataMap.self, relatedToEvent: self).forEach {
//            print("Event \(id)=\(isTriggered) affected \($0)")
            if $0 != inMapId {
                Map.onChange.fire((id: $0, object: nil))
            }
        }
        // reload any changed persons not the current one
        Event.getAffectedIds(ofType: DataPerson.self, relatedToEvent: self).forEach {
//            print("Event \(id)=\(isTriggered) affected \($0)")
            if $0 != inPersonId {
                Person.onChange.fire((id: $0, object: nil))
            }
        }
        // reload any changed items not the current one
        Event.getAffectedIds(ofType: DataItem.self, relatedToEvent: self).forEach {
//            print("Event \(id)=\(isTriggered) affected \($0)")
            if $0 != inItemId {
                Item.onChange.fire((id: $0, object: nil))
            }
        }
    }
}

// MARK: Dummy data for Interface Builder
extension Event {
    public static func getDummy(json: String? = nil) -> Event? {
        let json = json ?? "{\"id\":\"1.1\",\"gameVersion\":\"1\",\"name\":\"Unlocked Normandy\",\"description\":\"Dummy Event Description.\"}"
        if var baseEvent = DataEvent(serializedString: json) {
            baseEvent.isDummyData = true
            let event = Event(id: "1", generalData: baseEvent)
            return event
        }
        return nil
    }
}

// MARK: SerializedDataStorable
extension Event: SerializedDataStorable {

    public func getData() -> SerializableData {
        var list: [String: SerializedDataStorable?] = [:]
        list["id"] = id
        list["isTriggered"] = isTriggered
        list = serializeDateModifiableData(list: list)
        list = serializeGameModifyingData(list: list)
        list = serializeLocalCloudData(list: list)
        return SerializableData.safeInit(list)
    }
    
}

// MARK: SerializedDataRetrievable
extension Event: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data, let id = data["id"]?.string,
              let dataEvent = DataEvent.get(id: id),
              let gameSequenceUuid = data["gameSequenceUuid"]?.string
        else {
            return nil
        }
        
        self.init(id: id, gameSequenceUuid: gameSequenceUuid, generalData: dataEvent, data: data)
    }
    
    public mutating func setData(_ data: SerializableData) {
        id = data["id"]?.string ?? id
        if generalData.id != id {
            generalData = DataEvent.get(id: id) ?? generalData
        }
        
        unserializeDateModifiableData(data: data)
        unserializeGameModifyingData(data: data)
        unserializeLocalCloudData(data: data)
        
        isTriggered = data["isTriggered"]?.bool ?? isTriggered
        
        setGeneralData() // overrides isTriggered in this instance
    }
    
}

// MARK: DateModifiable
extension Event: DateModifiable {}

// MARK: GameModifying
extension Event: GameModifying {}

//MARK: Equatable
extension Event: Equatable {
    public static func ==(a: Event, b: Event) -> Bool { // not true equality, just same db row
        return a.id == b.id
    }
}

// MARK: Hashable
extension Event: Hashable {
    public var hashValue: Int { return id.hashValue }
}
