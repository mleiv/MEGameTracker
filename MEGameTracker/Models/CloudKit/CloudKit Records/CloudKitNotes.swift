//
//  GameNotes.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

extension Note: CloudDataStorable {
    
    /// (CloudDataStorable Protocol)
    /// Set any additional fields, specific to the object in question, for a cloud kit object.
    public func setAdditionalCloudFields(
        record: CKRecord
    ) {
        record.setValue(uuid as NSString, forKey: "id")
        record.setValue((gameSequenceUuid ?? "") as NSString, forKey: "gameSequenceUuid")
        record.setValue(gameVersion.stringValue as NSString, forKey: "gameVersion")
        record.setValue(shepardUuid as NSString, forKey: "shepardUuid")
        record.setValue(identifyingObject.serializedString, forKey: "identifyingObject")
        record.setValue(text, forKey: "text")
    }

    /// (CloudDataStorable Protocol)
    /// Takes one serialized cloud change and saves it.
    public static func saveOneFromCloud(
        changeSet: SerializableData,
        with manager: SimpleSerializedCoreDataManageable?
    ) -> Bool {
        if let recordId = changeSet["recordId"]?.string,
            let (id, uuid) = parseIdentifyingName(name: recordId),
            let shepardUuid = changeSet["shepardUuid"]?.string
        {
            // if identifyingObject fails, throw this note away - it can't be recovered :(
            guard let identifyingObject = IdentifyingObject(serializedString: changeSet["identifyingObject"]?.string ?? "") else { return true }
            
            var changeSet = changeSet
            changeSet["gameSequenceUuid"] = uuid.getData()
            var note = Note.get(uuid: id) ?? Note(uuid: id, identifyingObject: identifyingObject, shepardUuid: shepardUuid, gameSequenceUuid: uuid, data: nil)
            let pendingData = note.pendingCloudChanges
            // apply cloud changes
            note.setData(changeSet)
            note.isSavedToCloud = true
            // reapply local changes
            if let pendingData = pendingData {
                note.setData(pendingData)
                note.isSavedToCloud = false
                // re-store pending changes until object is saved to cloud
                note.pendingCloudChanges = pendingData
            }
            note.isSavedToCloud = true
            if note.save(with: manager) {
                print("Saved from cloud \(recordId)")
                return true
            } else {
                print("Save from cloud failed \(recordId)")
            }
        }
        return false
    }

    /// (CloudDataStorable Protocol)
    /// Delete a local object after directed by the cloud to do so.
    public static func deleteOneFromCloud(recordId: String) -> Bool {
        guard let (id, uuid) = parseIdentifyingName(name: recordId) else { return false }
        return delete(uuid: id, gameSequenceUuid: uuid)
    }
    
    /// (CloudDataStorable Protocol)
    /// Create a recordName for any cloud kit object.
    public static func getIdentifyingName(
        id: String,
        gameSequenceUuid: String?
    ) -> String {
        return "\(gameSequenceUuid ?? "")||\(id)"
    }
    
    /// Convenience version - get the static getIdentifyingName for easy instance reference.
    public func getIdentifyingName() -> String {
        return Note.getIdentifyingName(id: uuid, gameSequenceUuid: gameSequenceUuid)
    }
    
    /// (CloudDataStorable Protocol)
    /// Parses a cloud identifier into the parts needed to retrieve it from core data.
    public static func parseIdentifyingName(
        name: String
    ) -> ((id: String, gameSequenceUuid: String)?) {
        let pieces = name.components(separatedBy: "||")
        guard pieces.count == 2 else { return nil }
        return (id: pieces[1], gameSequenceUuid: pieces[0])
    }
    
    /// Used for parsing from records
    public static func getAll(
        identifiers: [String],
        with manager: SimpleSerializedCoreDataManageable?
    ) -> [Note] {
        return identifiers.flatMap { (identifier: String) in
            if let (id, _) = parseIdentifyingName(name: identifier) {
                return get(uuid: id, with: manager)
            }
            return nil
        }
    }
}
