//
//  CurrentGame.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/9/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

public struct GameSequence {

// MARK: Constants

    public typealias ShepardVersionIdentifier = (uuid: String, gameVersion: GameVersion)
    
// MARK: Properties
    public var id: String { return uuid }
    public var uuid: String
    public var shepard: Shepard?
    
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
    
    // Interface Builder
    public var isDummyData = false
    
// MARK: Computed Properties

    public var gameVersion: GameVersion {
        return shepard?.gameVersion ?? .game1
    }
    
// MARK: Change Listeners And Change Status Flags
    
    /// (DateModifiable) Flag to indicate that there are changes pending a core data sync.
    public var hasUnsavedChanges = false
    
    
// MARK: Initialization

    public init(uuid: String? = nil) {
        self.uuid = uuid ?? UUID().uuidString
        let shepard = Shepard(gameSequenceUuid: self.uuid, gameVersion: .game1)
        self.shepard = shepard
        markChanged()
    }
}
    

// MARK: Retrieval Functions of Related Data
extension GameSequence {
    
    public func getAllShepards() -> [Shepard] {
        return Shepard.getAll(gameSequenceUuid: uuid)
    }
    
}


// MARK: Data Change Actions
extension GameSequence {

    /// Changes current shepard to a different game version shepard, creating that shepard if necessary.
    /// Warning: due to App static current shepard signal, DO NOT call this directly.
    internal mutating func change(gameVersion newGameVersion: GameVersion) {
        guard newGameVersion != gameVersion else { return }
        // save prior shepard
        _ = shepard?.saveAnyChanges(isCascadeChanges: .down, isAllowDelay: false)
        // locate different gameVersion shepard
        guard var shepard = getShepardFromVersion(newGameVersion) else { return }
        // save if new
        if shepard.isNew {
            shepard.isNew = false
            addNewShepardVersion(shepard)
        }
        self.shepard = shepard
        markChanged()
        // save current game and shepard (to mark most recent)
        _ = save(isAllowDelay: false)
    }
    
    /// Used to change game version OR to load a shepard to test conditions against (see: Decision)
    public func getShepardFromVersion(_ newGameVersion: GameVersion) -> Shepard? {
        guard newGameVersion != gameVersion else { return nil }
        // locate new shepard
        if let foundShepard = Shepard.get(gameVersion: newGameVersion, gameSequenceUuid: uuid) {
            return foundShepard
        } else {
            let gender = shepard?.gender ?? .male
            var newShepard = Shepard(gameSequenceUuid: uuid, gender: gender, gameVersion: newGameVersion)
            // share all data from other game version:
            if let shepard = self.shepard {
                newShepard.setNewData(oldData: shepard.getData(), oldGame: shepard.gameVersion)
            }
            newShepard.isNew = true
            return newShepard
        }
    }
    
    fileprivate mutating func addNewShepardVersion(_ shepard: Shepard) {
        var shepard = shepard
        shepard.gameSequenceUuid = uuid
        _ = shepard.saveAnyChanges(isCascadeChanges: .down) //isAllowDelay = true
//        markChanged()
//        _ = saveAnyChanges() // this is called later in GameSequence change(gameVersion:)
    }
}

// MARK: Dummy data for Interface Builder
extension GameSequence {
    public static func getDummy() -> GameSequence? {
        var game = GameSequence()
        game.isDummyData = true
        game.shepard = Shepard.getDummy()
        game.shepard?.gameSequenceUuid = game.uuid
        return game
    }
}

// MARK: SerializedDataStorable
extension GameSequence: SerializedDataStorable {

    public func getData() -> SerializableData {
        var list: [String: SerializedDataStorable?] = [:]
        list["uuid"] = uuid
        list["lastPlayedShepard"] = shepard?.uuid
        list = serializeDateModifiableData(list: list)
        list = serializeLocalCloudData(list: list)
        return SerializableData.safeInit(list)
    }
    
}

// MARK: SerializedDataRetrievable
extension GameSequence: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data, let uuid = data["uuid"]?.string
        else {
            return nil
        }
        self.uuid = uuid
        
        setData(data)
    }
    
    public mutating func setData(_ data: SerializableData, isSkipLoadingShepard: Bool) {
        self.uuid = data["uuid"]?.string ?? uuid
        if !isSkipLoadingShepard {
            if let lastPlayedShepardUuid = data["lastPlayedShepard"]?.string,
                lastPlayedShepardUuid != self.shepard?.uuid,
                let shepard = Shepard.get(uuid: lastPlayedShepardUuid) {
                self.shepard = shepard
            } else {
                // you only reach this if there was an error saving shepard last game save.
                self.shepard = Shepard.lastPlayed(gameSequenceUuid: uuid)
                          ?? self.shepard
                          ?? Shepard(gameSequenceUuid: self.uuid, gameVersion: .game1)
                markChanged()
            }
        }
        
        //optional values
        unserializeDateModifiableData(data: data)
        unserializeLocalCloudData(data: data)
    }
    
    
    // Protocol adherence - no extra parameters.
    public mutating func setData(_ data: SerializableData) {
        setData(data, isSkipLoadingShepard: false)
    }
    
}

// MARK: DateModifiable
extension GameSequence: DateModifiable {
    
    public mutating func markChanged() {
        touch()
        notifySaveToCloud(fields: ["lastPlayedShepard": shepard?.uuid ?? ""])
        hasUnsavedChanges = true
    }
}

// MARK: Sorting
extension GameSequence {

    static func sort(_ a: GameSequence, b: GameSequence) -> Bool {
        return (a.shepard?.modifiedDate ?? Date()).compare(b.shepard?.modifiedDate ?? Date()) == .orderedDescending
    }
}

// MARK: Equatable
extension GameSequence: Equatable {}

public func ==(lhs: GameSequence, rhs: GameSequence) -> Bool { // not true equality, just same db row
    return lhs.uuid == rhs.uuid
}

