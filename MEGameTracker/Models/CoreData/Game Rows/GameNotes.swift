//
//  GameNotes.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/19/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension Note: SimpleSerializedCoreDataStorable {

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GameNotes

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
//        setDateModifiableColumnsOnSave(coreItem: coreItem) //TODO
		coreItem.uuid = uuid.uuidString
		coreItem.gameSequenceUuid = gameSequenceUuid?.uuidString
		coreItem.gameVersion = gameVersion.stringValue
		coreItem.shepardUuid = shepardUuid?.uuidString
		coreItem.identifyingObject = identifyingObject.flattenedString
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
	}

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Alters the predicate to retrieve only the row equal to this object.
	public func setIdentifyingPredicate(
		fetchRequest: NSFetchRequest<EntityType>
	) {
		fetchRequest.predicate = NSPredicate(
			format: "(%K == %@)",
			#keyPath(GameNotes.uuid), uuid.uuidString
		)
	}
}

extension Note {

// MARK: Save

	public mutating func saveAnyChanges(
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		if hasUnsavedChanges {
			let isSaved = save(with: manager)
			return isSaved
		}
		return true
	}

	public mutating func saveAnyChanges() -> Bool {
		return saveAnyChanges(with: nil)
	}

	public mutating func save( // override to mark game sequence changed also
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		let manager = manager ?? defaultManager
		let isSaved = manager.saveValue(item: self)
		if isSaved {
			hasUnsavedChanges = false
			if App.current.game?.uuid == gameSequenceUuid {
				markGameChanged(with: manager)
			}
		}
		return isSaved
	}

// MARK: Delete

	public static func delete(
		uuid: UUID,
		gameSequenceUuid: UUID,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Bool {
		if !GamesDataBackup.current.isSyncing {
			// save record for CloudKit
			notifyDeleteToCloud(uuid: uuid, gameSequenceUuid: gameSequenceUuid, with: manager)
		}
		return deleteAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(GameNotes.uuid), uuid.uuidString
			)
		}
	}

	/// Stores a row before delete
	public static func notifyDeleteToCloud(
		uuid: UUID,
		gameSequenceUuid: UUID,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) {
let manager = CoreDataManager2.current
		let deletedRows: [DeletedRow] = [DeletedRow(
			source: Note.entityName,
			identifier: getIdentifyingName(id: uuid.uuidString, gameSequenceUuid: gameSequenceUuid)
		)]
		_ = DeletedRow.saveAll(items: deletedRows, with: manager)
		GamesDataBackup.current.isPendingCloudChanges = true
	}

	/// Only called by GameSequence. This does not notify cloud or cascade delete, so do not call it in other places.
	public static func deleteAll(
		gameSequenceUuid: UUID,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Bool {
		// don't have to notify: GameSequence did that for you
		return deleteAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(GameNotes.gameSequenceUuid), gameSequenceUuid.uuidString
			)
		}
	}

// MARK: Additional Convenience Gets

	public static func get(
		uuid: UUID,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Note? {
		return get(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(GameNotes.uuid), uuid.uuidString
			)
		}
	}

	public static func getAll(
		uuids: [UUID],
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [Note] {
		return getAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K in %@)",
				#keyPath(GameNotes.uuid), uuids.map{ $0.uuidString }
			)
		}
	}

	public static func getAll(
		identifyingObject: IdentifyingObject,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [Note] {
		return getAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(GameNotes.identifyingObject), identifyingObject.flattenedString
			)
		}
	}

}
