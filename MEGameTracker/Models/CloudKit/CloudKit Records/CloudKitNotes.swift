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
        record.setValue(uuid.uuidString as NSString, forKey: "id")
        record.setValue((gameSequenceUuid?.uuidString ?? "") as NSString, forKey: "gameSequenceUuid")
        record.setValue(gameVersion.stringValue as NSString, forKey: "gameVersion")
        record.setValue((shepardUuid?.uuidString ?? "") as NSString, forKey: "shepardUuid")
        record.setValue(identifyingObject.serializedString, forKey: "identifyingObject")
        record.setValue(text, forKey: "text")
    }

    /// (CloudDataStorable Protocol)
    /// Alter any CK items before handing to codable to modify/create object
    public func getAdditionalCloudFields(changeRecord: CloudDataRecordChange) -> [String: Any?] {
        var changes = changeRecord.changeSet
        changes["gameSequenceUuid"] = self.gameSequenceUuid //?
        changes.removeValue(forKey: "identifyingObject") // fallback to element's value
        changes.removeValue(forKey: "lastRecordData")
        return changes
    }

    /// (CloudDataStorable Protocol)
    /// Takes one serialized cloud change and saves it.
    public static func saveOneFromCloud(
        changeRecord: CloudDataRecordChange,
        with manager: CodableCoreDataManageable?
    ) -> Bool {
        let recordId = changeRecord.recordId
        if let (id, gameUuid) = parseIdentifyingName(name: recordId),
            let noteUuid = UUID(uuidString: id),
            let shepardUuidString = changeRecord.changeSet["shepardUuid"] as? String,
            let shepardUuid = UUID(uuidString: shepardUuidString) {
            // if identifyingObject fails, throw this note away - it can't be recovered :(
            guard let json = changeRecord.changeSet["identifyingObject"] as? String,
                let decoder = manager?.decoder,
                let identifyingObject = try? decoder.decode(
                        IdentifyingObject.self,
                        from: json.data(using: .utf8) ?? Data()
                )
            else {
                return true
            }

            var element = Note.get(uuid: noteUuid) ?? Note(
                                                identifyingObject: identifyingObject,
                                                uuid: noteUuid,
                                                shepardUuid: shepardUuid,
                                                gameSequenceUuid: gameUuid
                                            )
            // apply cloud changes
            element.rawData = nil
            let changes = element.getAdditionalCloudFields(changeRecord: changeRecord)
            element = element.changed(changes)
            element.isSavedToCloud = true
            // reapply any local changes
            if !element.pendingCloudChanges.isEmpty {
                element = element.changed(element.pendingCloudChanges.dictionary)
                element.isSavedToCloud = false
            }
            // save locally
            if element.save(with: manager) {
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
        guard let (noteUuid, gameUuid) = parseIdentifyingName(name: recordId) else { return false }
        if let noteUuid = UUID(uuidString: noteUuid) {
            return delete(uuid: noteUuid, gameSequenceUuid: gameUuid)
        } else {
            defaultManager.log("Failed to parse note uuid: \(recordId)")
            return false
        }
    }

    /// (CloudDataStorable Protocol)
    /// Create a recordName for any cloud kit object.
    public static func getIdentifyingName(
        id: String,
        gameSequenceUuid: UUID?
    ) -> String {
        return "\(gameSequenceUuid?.uuidString ?? "")||\(id)"
    }

    /// Convenience version - get the static getIdentifyingName for easy instance reference.
    public func getIdentifyingName() -> String {
        return Note.getIdentifyingName(id: uuid.uuidString, gameSequenceUuid: gameSequenceUuid)
    }

    /// (CloudDataStorable Protocol)
    /// Parses a cloud identifier into the parts needed to retrieve it from core data.
    public static func parseIdentifyingName(
        name: String
    ) -> (id: String, gameSequenceUuid: UUID)? {
        let pieces = name.components(separatedBy: "||")
        guard pieces.count == 2 else { return nil }
        if let gameSequenceUuid = UUID(uuidString: pieces[0]) {
            return (id: pieces[1], gameSequenceUuid: gameSequenceUuid)
        } else {
            defaultManager.log("No Game UUID found for: \(name)")
            return nil
        }
    }

    /// Used for parsing from records
    public static func getAll(
        identifiers: [String],
        with manager: CodableCoreDataManageable?
    ) -> [Note] {
        return identifiers.map { (identifier: String) in
            if let (id, _) = parseIdentifyingName(name: identifier),
                let uuid = UUID(uuidString: id) {
                return get(uuid: uuid, with: manager)
            }
            return nil
        }.filter({ $0 != nil }).map({ $0! })
    }
}
