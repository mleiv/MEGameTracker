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
        record.setValue(uuid as NSString, forKey: "id")
        record.setValue(gameSequenceUuid as NSString, forKey: "gameSequenceUuid")
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
        changeSet: SerializableData,
        with manager: SimpleSerializedCoreDataManageable?
    ) -> Bool {
        if let recordId = changeSet["recordId"]?.string,
            let (uuid, gameSequenceUuid) = parseIdentifyingName(name: recordId),
            let gameVersion = GameVersion(rawValue: changeSet["gameVersion"]?.string ?? "0")
        {
            var shepard = Shepard.get(uuid: uuid) ?? Shepard(uuid: uuid, gameSequenceUuid: gameSequenceUuid, gameVersion: gameVersion, data: nil)
            let pendingData = shepard.pendingCloudChanges
            // apply cloud changes
            shepard.setData(changeSet, isInternal: true)
            if let image = GamesDataBackup.current.getCachedImage(recordId: recordId, key: "photoFile") {
                _ = shepard.savePhoto(image: image, isSave: false)
            }
            shepard.isSavedToCloud = true
            // reapply local changes
            if let pendingData = pendingData {
                shepard.setData(pendingData, isInternal: true)
                shepard.isSavedToCloud = false
                // re-store pending changes until object is saved to cloud
                shepard.pendingCloudChanges = pendingData
            }
            if shepard.save(isCascadeChanges: .none, isAllowDelay: false, with: manager) {
                print("Saved from cloud \(recordId) \(shepard.fullName)")
                return true
            } else {
                print("Save from cloud failed \(recordId) \(shepard.fullName)")
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
        gameSequenceUuid: String?
    ) -> String {
        return "\(gameSequenceUuid ?? "")||\(id)"
    }
    
    /// Convenience version - get the static getIdentifyingName for easy instance reference.
    public func getIdentifyingName() -> String {
        return Shepard.getIdentifyingName(id: uuid, gameSequenceUuid: gameSequenceUuid)
    }
    
    /// (CloudDataStorable Protocol)
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
    ) -> [Shepard] {
        return identifiers.flatMap { (identifier: String) in
            if let (id, _) = parseIdentifyingName(name: identifier) {
                return get(uuid: id, with: manager)
            }
            return nil
        }
    }
}
