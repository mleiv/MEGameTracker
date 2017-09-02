//
//  GameShepards.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

extension Shepard: CloudDataStorable {

    /// (CloudDataStorable Protocol)
    /// Set any additional fields, specific to the object in question, for a cloud kit object.
    public func setAdditionalCloudFields(record: CKRecord) {
        record.setValue(uuid.uuidString as NSString, forKey: "id")
        record.setValue(gameSequenceUuid.uuidString as NSString, forKey: "gameSequenceUuid")
        record.setValue(gameVersion.stringValue as NSString, forKey: "gameVersion")
        record.setValue(level as NSNumber, forKey: "level")
        record.setValue(paragon as NSNumber, forKey: "paragon")
        record.setValue(renegade as NSNumber, forKey: "renegade")
        record.setValue((gender == .male ? "M" : "F") as NSString, forKey: "gender")
        record.setValue((name.stringValue ?? "") as NSString, forKey: "name")
        record.setValue(appearance.format() as NSString, forKey: "appearance")
        record.setValue(origin.stringValue as NSString, forKey: "origin")
        record.setValue(reputation.stringValue as NSString, forKey: "reputation")
        record.setValue(classTalent.stringValue as NSString, forKey: "class")
        record.setValue((loveInterestId ?? "") as NSString, forKey: "loveInterestId")
        record.setValue((photo?.stringValue ?? "") as NSString, forKey: "photo")
        if let photo = photo, photo.isCustomSavedPhoto {
            if let url = photo.getUrl() {
                record.setValue(CKAsset(fileURL: url), forKey: "photoFile")
            } else {
                record.setValue(nil, forKey: "photoFile")
            }
        }
    }

    /// (CloudDataStorable Protocol)
    /// Takes one serialized cloud change and saves it.
    public static func saveOneFromCloud(
        changeRecord: CloudDataRecordChange,
        with manager: CodableCoreDataManageable?
    ) -> Bool {
        let recordId = changeRecord.recordId
        if let (uuidString, gameSequenceUuid) = parseIdentifyingName(name: recordId),
            let uuid = UUID(uuidString: uuidString),
            let gameVersion = GameVersion(rawValue: changeRecord.changeSet["gameVersion"] as? String ?? "0") {
            var element = Shepard.get(uuid: uuid)
                            ?? Shepard(
                                gameSequenceUuid: gameSequenceUuid,
                                uuid: uuid,
                                gameVersion: gameVersion
                            )
            // apply cloud changes
            element = element.changed(changeRecord.changeSet)
            // special case
            if let image = GamesDataBackup.current.getCachedImage(recordId: recordId, key: "photoFile") {
                _ = element.savePhoto(image: image, isSave: false)
            }
            element.isSavedToCloud = true
            // reapply any local changes
            if !element.pendingCloudChanges.isEmpty {
                element = element.changed(element.pendingCloudChanges.dictionary)
                element.isSavedToCloud = false
            }
            // save locally
            if element.save(isCascadeChanges: .none, isAllowDelay: false, with: manager) {
                print("Saved from cloud \(recordId) \(element.fullName)")
                return true
            } else {
                print("Save from cloud failed \(recordId) \(element.fullName)")
            }
        }
        return false
    }

    /// (CloudDataStorable Protocol)
    /// Delete a local object after directed by the cloud to do so.
    public static func deleteOneFromCloud(recordId: String) -> Bool {
        guard let (id, gameSequenceUuid) = parseIdentifyingName(name: recordId) else { return false }
        return delete(uuid: id, gameSequenceUuid: gameSequenceUuid)
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
        return Shepard.getIdentifyingName(id: uuid.uuidString, gameSequenceUuid: gameSequenceUuid)
    }

    /// (CloudDataStorable Protocol)
    public static func parseIdentifyingName(
        name: String
    ) -> ((id: String, gameSequenceUuid: UUID)?) {
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
    ) -> [Shepard] {
        return identifiers.map { (identifier: String) in
            if let (id, _) = parseIdentifyingName(name: identifier),
                let uuid = UUID(uuidString: id) {
                return get(uuid: uuid, with: manager)
            }
            return nil
        }.filter({ $0 != nil }).map({ $0! })
    }
}
