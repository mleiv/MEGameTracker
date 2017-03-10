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
		record.setValue(uuid as NSString, forKey: "id")
		if let shepard = self.shepard {
			record.setValue(shepard.uuid as NSString, forKey: "lastPlayedShepard")
		}
	}

	/// (CloudDataStorable Protocol)
	/// Takes one serialized cloud change and saves it.
	public static func saveOneFromCloud(
		changeSet: SerializableData,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		if let recordId = changeSet["recordId"]?.string,
			let (_, uuid) = parseIdentifyingName(name: recordId) {
			var game = GameSequence.get(uuid: uuid) ?? GameSequence(uuid: uuid)
			let pendingData = game.pendingCloudChanges
			// apply cloud changes
			game.setData(changeSet, isSkipLoadingShepard: true)
			game.isSavedToCloud = true
			if let lastPlayedShepardUuid = pendingData?["lastPlayedShepard"]?.string
											?? changeSet["lastPlayedShepard"]?.string {
				game.shepard = Shepard(uuid: lastPlayedShepardUuid, gameSequenceUuid: uuid)
				// dummy copy, just to keep ref to shepardUuid
			}
			// don't reapply local changes
			game.isSavedToCloud = true
			if game.save(isCascadeChanges: .none, isAllowDelay: false, with: manager) {
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
		gameSequenceUuid: String?
	) -> String {
		return "\(gameSequenceUuid ?? "")||\(id)"
	}

	/// Convenience version - get the static getIdentifyingName for easy instance reference.
	public func getIdentifyingName() -> String {
		return GameSequence.getIdentifyingName(id: "", gameSequenceUuid: uuid)
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
	) -> [GameSequence] {
		return identifiers.flatMap { (identifier: String) in
			if let (_, uuid) = parseIdentifyingName(name: identifier) {
				return get(uuid: uuid, with: manager)
			}
			return nil
		}
	}
}
