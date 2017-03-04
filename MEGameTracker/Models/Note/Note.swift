//
//  Note.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/19/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

public struct Note {
// MARK: Constants

// MARK: Properties
    
    public internal(set) var uuid: String
    public internal(set) var shepardUuid: String
    public internal(set) var identifyingObject: IdentifyingObject
    
    public fileprivate(set) var text: String?
    
    public var gameVersion: GameVersion
    
    /// (GameModifying Protocol) 
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

// MARK: Change Listeners And Change Status Flags
    
    /// (DateModifiable) Flag to indicate that there are changes pending a core data sync.
    public var hasUnsavedChanges = false
    public static var onChange = Signal<(id: String, object: Note?)>()
    
// MARK: Initialization
    
    public init(
        identifyingObject: IdentifyingObject,
        shepardUuid: String? = nil,
        gameSequenceUuid: String? = nil
    ) {
        uuid = "\(UUID().uuidString)"
        self.identifyingObject = identifyingObject
        self.gameVersion = App.current.gameVersion
        self.shepardUuid = shepardUuid ?? (App.current.game?.shepard?.uuid ?? "")
        self.gameSequenceUuid = gameSequenceUuid ?? App.current.game?.uuid
    }
    
    public init(
        uuid: String,
        identifyingObject: IdentifyingObject,
        shepardUuid: String? = nil,
        gameSequenceUuid: String? = nil,
        gameVersion: GameVersion? = nil,
        data: SerializableData?
    ) {
        self.init(identifyingObject: identifyingObject, shepardUuid: shepardUuid, gameSequenceUuid: gameSequenceUuid)
        self.uuid = uuid
        if let data = data {
            setData(data)
        } else if let gameVersion = gameVersion {
            self.gameVersion = gameVersion
        }
    }

}

// MARK: Retrieval Functions of Related Data

extension Note {
    public static func getDummyNote(json: String? = nil) -> Note? {
        let json = json ?? "{\"uuid\":1,\"shepardUuid\":1,\"identifyingObject\":{\"type\":\"Map\",\"id\":1},\"text\":\"A note.\"}"
        return Note(serializedString: json)
    }
}

// MARK: Data Change Actions
extension Note {
    public mutating func change(text: String, isSave: Bool = true, isNotify: Bool = true) {
        if text != self.text {
            self.text = text
            hasUnsavedChanges = true
            markChanged()
            notifySaveToCloud(fields: ["text": text])
            if isSave {
                _ = saveAnyChanges()
            }
            if isNotify {
                Note.onChange.fire((id: self.uuid, object: self))
            }
        }
    }
}

// MARK: SerializedDataStorable
extension Note: SerializedDataStorable {

    public func getData() -> SerializableData {
        var list: [String: SerializedDataStorable?] = [:]
        list["uuid"] = uuid
//        list["gameSequenceUuid"] = gameSequenceUuid // GameModifying
        list["shepardUuid"] = shepardUuid
        list["text"] = text
        list["identifyingObject"] = identifyingObject.getData()
        list["gameVersion"] = gameVersion.stringValue
        list = serializeDateModifiableData(list: list)
        list = serializeGameModifyingData(list: list)
        list = serializeLocalCloudData(list: list)
        return SerializableData.safeInit(list)
    }
    
}

// MARK: SerializedDataRetrievable
extension Note: SerializedDataRetrievable {
    
    public init?(data: SerializableData?) {
        guard let data = data,
              let uuid = data["uuid"]?.string,
              let gameSequenceUuid = data["gameSequenceUuid"]?.string,
              let shepardUuid = data["shepardUuid"]?.string,
              let identifyingObject = IdentifyingObject(data: data["identifyingObject"])
        else { return nil }
        
        self.init(uuid: uuid, identifyingObject: identifyingObject, shepardUuid: shepardUuid, gameSequenceUuid: gameSequenceUuid, data: data)
    }
    
    public mutating func setData(_ data: SerializableData) {
        self.uuid = data["uuid"]?.string ?? uuid
        self.gameSequenceUuid = data["gameSequenceUuid"]?.string ?? gameSequenceUuid
        self.shepardUuid = data["shepardUuid"]?.string ?? shepardUuid
        self.identifyingObject = IdentifyingObject(data: data["identifyingObject"]) ?? identifyingObject
        self.gameVersion = GameVersion(rawValue: data["gameVersion"]?.string ?? "0") ?? gameVersion
        
        text = data["text"]?.string
        
        unserializeDateModifiableData(data: data)
        unserializeGameModifyingData(data: data)
        unserializeLocalCloudData(data: data)
    }
    
}

// MARK: DateModifiable
extension Note: DateModifiable {}

// MARK: GameModifying
extension Note: GameModifying {}

//MARK: Equatable
extension Note: Equatable {
    public static func ==(a: Note, b: Note) -> Bool { // not true equality, just same db row
        return a.uuid == b.uuid
    }
}

// MARK: Hashable
extension Note: Hashable {
    public var hashValue: Int { return uuid.hashValue }
}
