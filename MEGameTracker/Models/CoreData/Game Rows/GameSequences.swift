//
//  GameSequences.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/31/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension GameSequence: SimpleSerializedCoreDataStorable {

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GameSequences

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		setDateModifiableColumnsOnSave(coreItem: coreItem)
		coreItem.uuid = uuid
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
	}

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Alters the predicate to retrieve only the row equal to this object.
	public func setIdentifyingPredicate(
		fetchRequest: NSFetchRequest<EntityType>
	) {
		fetchRequest.predicate = NSPredicate(
			format: "(%K == %@)",
			#keyPath(GameSequences.uuid), uuid
		)
	}
}

extension GameSequence {

	/// The closure type for editing fetch requests.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

// MARK: Save

	/// Save if there were changes, cascade save if so specified, delay save to interval timer by default.
	public mutating func saveAnyChanges(
		isCascadeChanges: EventDirection = .down,
		isAllowDelay: Bool = true,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Bool {
		if hasUnsavedChanges {
			if isAllowDelay {
				App.current.hasUnsavedChanges = true
				return true // not an error
			} else {
				let isSaved = save(isCascadeChanges: isCascadeChanges, isAllowDelay: false, with: manager)
				return isSaved
			}
		}
		return true
	}

	/// Save the game value, cascade save if so specified, delaying for interval timer by default.
	public mutating func save(
		isCascadeChanges: EventDirection,
		isAllowDelay: Bool,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		hasUnsavedChanges = true // force this
		if isAllowDelay {
			App.current.hasUnsavedChanges = true
			return true // not an error
		}
		let manager = manager ?? defaultManager
		var isSaved = true
		if isCascadeChanges != .none && isCascadeChanges != .up && !GamesDataBackup.current.isSyncing {
			isSaved = isSaved
				&& (shepard?.saveAnyChanges(isCascadeChanges: .down, isAllowDelay: false, with: manager) ?? false)
		}
		isSaved = isSaved && manager.saveValue(item: self)
		if isSaved {
			hasUnsavedChanges = false
		}
		return isSaved
	}

	/// Convenience version of save:isCascadeChanges:isAllowDelay:manager (no manager required)
	public mutating func save(
		isCascadeChanges: EventDirection = .down,
		isAllowDelay: Bool
	) -> Bool {
		return save(isCascadeChanges: isCascadeChanges, isAllowDelay: isAllowDelay, with: nil)
	}

	/// (SimpleSerializedCoreDataStorable Protocol override)
	public mutating func save(
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		return save(isCascadeChanges: .down, isAllowDelay: true, with: manager)
	}

	/// Convenience - no isAllowDelay required
	public mutating func save(
		isCascadeChanges: EventDirection,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Bool {
		return save(isCascadeChanges: isCascadeChanges, isAllowDelay: true, with: manager)
	}

// MARK: Delete

	/// Delete the value matching the ids specified, and cascades the delete to all game-specific data.
	/// (Only ever called by cloudkit when syncing.)
	public static func delete(
		uuid: String,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Bool {
		let manager = manager ?? defaultManager

		var isDeleted = true

		if !GamesDataBackup.current.isSyncing {
			// save record for CloudKit
			notifyDeleteToCloud(uuid: uuid, with: manager)
		}

		// mass delete all related objects
		// these may be redeleted individually, but I want to clean up everything. 
		isDeleted = isDeleted && Decision.deleteAll(gameSequenceUuid: uuid, with: manager)
		isDeleted = isDeleted && Item.deleteAll(gameSequenceUuid: uuid, with: manager)
		isDeleted = isDeleted && Map.deleteAll(gameSequenceUuid: uuid, with: manager)
		isDeleted = isDeleted && Mission.deleteAll(gameSequenceUuid: uuid, with: manager)
		isDeleted = isDeleted && Note.deleteAll(gameSequenceUuid: uuid, with: manager)
		isDeleted = isDeleted && Person.deleteAll(gameSequenceUuid: uuid, with: manager)
		isDeleted = isDeleted && Shepard.deleteAll(gameSequenceUuid: uuid, with: manager)

		isDeleted = true // ignore the above stuff for now - we may have duplicate calls due to changes

		// delete self (X3)
		isDeleted = isDeleted && GameSequence.deleteAll { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(uuid = %@)", uuid)
		}

		return isDeleted
	}

	/// Stores a row before delete
	public static func notifyDeleteToCloud(
		uuid: String,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) {
		var deletedRows: [DeletedRow] = []

		deletedRows += getAllIdentifiers(ofType: Decision.self, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid = %@)", uuid)
		}.map {
			return DeletedRow(
				source: Decision.entityName,
				identifier: Decision.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
			)
		}

		deletedRows += getAllIdentifiers(ofType: Event.self, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid = %@)", uuid)
		}.map {
			return DeletedRow(
				source: Event.entityName,
				identifier: Event.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
			)
		}

		deletedRows += getAllIdentifiers(ofType: Item.self, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid = %@)", uuid)
		}.map {
			return DeletedRow(
				source: Item.entityName,
				identifier: Item.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
			)
		}

		deletedRows += getAllIdentifiers(ofType: Map.self, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid = %@)", uuid)
		}.map {
			return DeletedRow(
				source: Map.entityName,
				identifier: Map.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
			)
		}

		deletedRows += getAllIdentifiers(ofType: Mission.self, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid = %@)", uuid)
		}.map {
			return DeletedRow(
				source: Mission.entityName,
				identifier: Mission.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
			)
		}

		deletedRows += getAllIdentifiers(ofType: Note.self, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid = %@)", uuid)
		}.map {
			return DeletedRow(
				source: Note.entityName,
				identifier: Note.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
			)
		}

		deletedRows += getAllIdentifiers(ofType: Person.self, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid = %@)", uuid)
		}.map {
			return DeletedRow(
				source: Person.entityName,
				identifier: Person.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
			)
		}

		deletedRows += getAllIdentifiers(ofType: Shepard.self, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid = %@)", uuid)
		}.map {
			return DeletedRow(
				source: Shepard.entityName,
				identifier: Shepard.getIdentifyingName(id: $0.id, gameSequenceUuid: $0.gameSequenceUuid)
			)
		}

		deletedRows += [DeletedRow(
			source: GameSequence.entityName,
			identifier: getIdentifyingName(id: "", gameSequenceUuid: uuid)
		)]

		_ = DeletedRow.saveAll(items: deletedRows, with: manager)
		GamesDataBackup.current.isPendingCloudChanges = true
	}

	internal static func getAllIdentifiers<T: CloudDataStorable & SimpleSerializedCoreDataStorable>(
		ofType type: T.Type,
		with manager: SimpleSerializedCoreDataManageable? = nil,
		alterFetchRequest: @escaping ((NSFetchRequest<T.EntityType>) -> Void) = { _ in }
	) -> [(id: String, gameSequenceUuid: String)] {
		let manager = manager ?? defaultManager
		var result: [(id: String, gameSequenceUuid: String)] = []
		autoreleasepool {
			result = manager.getAllTransformed(
				transformEntity: {
					if $0 is GameDecisions
						|| $0 is GameEvents
						|| $0 is GameItems
						|| $0 is GameMaps
						|| $0 is GameMissions
						|| $0 is GamePersons {
						if let id = $0.value(forKey: "id") as? String,
							let uuid = $0.value(forKey: "gameSequenceUuid") as? String {
							return (id: id, gameSequenceUuid: uuid)
						}
					} else if $0 is GameShepards
						|| $0 is GameNotes {
						if let id = $0.value(forKey: "uuid") as? String,
							let uuid = $0.value(forKey: "gameSequenceUuid") as? String {
							return (id: id, gameSequenceUuid: uuid)
						}
					}
					return nil
				},
				alterFetchRequest: alterFetchRequest
			)
		}
		return result
	}

// MARK: Additional Convenience Methods

	/// Get game with id.
	public static func get(
		uuid: String,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> GameSequence? {
		return get(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(GameSequences.uuid), uuid
			)
		}
	}

	/// Get all games with ids.
	public static func getAll(
		uuids: [String],
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [GameSequence] {
		return getAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K in %@)",
				#keyPath(GameSequences.uuid), uuids
			)
		}
	}

	/// Get all matching shepard ids.
	public static func getAllIds(
		with manager: SimpleSerializedCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType> = { _ in }
	) -> [String] {
		let manager = manager ?? defaultManager
		var result: [String] = []
		autoreleasepool {
			result = manager.getAllTransformed(
				transformEntity: { $0.value(forKey: "uuid") as? String },
				alterFetchRequest: alterFetchRequest
			)
		}
		return result
	}

	/// Get game with most recent modifiedDate.
	/// This is only called if App fails to save/load the current game (like, first time cloud sync).
	public static func lastPlayed(
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> GameSequence? {
		let manager = manager ?? defaultManager
		var result: GameSequence?
		autoreleasepool {
			if let row: GameSequences = manager.getOne(alterFetchRequest: { fetchRequest in
					fetchRequest.sortDescriptors = [
						NSSortDescriptor(key: #keyPath(GameSequences.modifiedDate), ascending: false)
					]
				}),
				let uuid = row.value(forKeyPath:  #keyPath(GameSequences.uuid)) as? String {
				print("Last Played Game: \(uuid) \(row.value(forKeyPath:  #keyPath(GameSequences.modifiedDate)))")
				result = get(uuid: uuid, with: manager)
			}
		}
		return result
	}

}
