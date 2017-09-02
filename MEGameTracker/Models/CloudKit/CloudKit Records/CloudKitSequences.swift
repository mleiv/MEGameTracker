//
//  GameSequences.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CloudKit
import CoreData

extension GameSequence: CloudDataStorable {

	/// (CloudDataStorable Protocol)
	/// Set any additional fields, specific to the object in question, for a cloud kit object.
	public func setAdditionalCloudFields(record: CKRecord) {
		record.setValue(uuid.uuidString as NSString, forKey: "id")
		if let shepard = self.shepard {
			record.setValue(shepard.uuid.uuidString as NSString, forKey: "lastPlayedShepard")
		}
	}

	/// (CloudDataStorable Protocol)
	/// Takes one serialized cloud change and saves it.
	public static func saveOneFromCloud(
        changeRecord: CloudDataRecordChange,
		with manager: CodableCoreDataManageable?
	) -> Bool {
        let recordId = changeRecord.recordId
        if let (_, uuid) = parseIdentifyingName(name: recordId) {
			var element = GameSequence.get(uuid: uuid) ?? GameSequence(uuid: uuid)
            // apply cloud changes
            element = element.changed(changeRecord.changeSet)
            element.isSavedToCloud = true
            // reapply any local changes
            if !element.pendingCloudChanges.isEmpty {
                element = element.changed(element.pendingCloudChanges.dictionary)
                element.isSavedToCloud = false
            }
            // save locally
			if element.save(isCascadeChanges: .none, isAllowDelay: false, with: manager) {
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
		guard let (_, uuid) = parseIdentifyingName(name: recordId) else { return false }
		return App.current.delete(uuid: uuid)
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
		return GameSequence.getIdentifyingName(id: "", gameSequenceUuid: uuid)
	}

	/// (CloudDataStorable Protocol)
	/// Parses a cloud identifier into the parts needed to retrieve it from core data.
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
	) -> [GameSequence] {
        return identifiers.map { (identifier: String) in
            if let (id, _) = parseIdentifyingName(name: identifier),
                let uuid = UUID(uuidString: id) {
                return get(uuid: uuid, with: manager)
            }
            return nil
        }.filter({ $0 != nil }).map({ $0! })
	}
}
