//
//  GameEvents.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/15/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension Event: GameRowStorable {

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GameEvents

	/// (GameRowStorable Protocol)
	/// Corresponding data entity for this game entity.
	public typealias DataRowType = DataEvent

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
		setDateModifiableColumnsOnSave(coreItem: coreItem)
		coreItem.id = id
		coreItem.gameSequenceUuid = gameSequenceUuid
		coreItem.isTriggered = isTriggered ? 1 : 0
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
		coreItem.dataParent = generalData.entity(context: coreItem.managedObjectContext)
	}

	/// (GameRowStorable Protocol)
	/// Create a new game entity value for the game uuid given using the data value given.
	public static func create(
		using data: DataRowType,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Event {
		return Event(id: data.id, generalData: data)
	}
}

extension Event {

// MARK: Additional Convenience Methods

	/// Get all events from the specified game version.
	public static func getAll(
		gameVersion: GameVersion,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [Event] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K == %@) OR (%K == nil))",
				#keyPath(DataEvents.gameVersion), gameVersion.stringValue,
				#keyPath(DataEvents.gameVersion)
			)
		}
	}

	/// Get an event by id, and assign it a specific type.
	public static func get(
		id: String?,
		type: EventType,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Event? {
		guard let id = id, !id.isEmpty else { return nil }
		var one = get(id: id, with: manager)
		one?.type = type
		return one
	}

	/// Return all events dependent on level score. This depends on the event being properly named.
	public static func getLevels(
		gameVersion: GameVersion,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [Event] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K MATCHES [cd] %@) AND (%K == %@))",
				#keyPath(DataEvents.id), "Level \\d+",
				#keyPath(DataEvents.gameVersion), gameVersion.stringValue
			)
		}
	}

	/// Return all events dependent on paragon score. This depends on the event being properly named.
	public static func getParagons(
		gameVersion: GameVersion,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [Event] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K MATCHES [cd] %@) AND (%K == %@))",
				#keyPath(DataEvents.id), "%Paragon \\d+",
				#keyPath(DataEvents.gameVersion), gameVersion.stringValue
			)
		}
	}

	/// Return all events dependent on renegade score. This depends on the event being properly named.
	public static func getRenegades(
		gameVersion: GameVersion,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [Event] {
		return getAllFromData(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "((%K MATCHES [cd] %@) AND (%K == %@))",
				#keyPath(DataEvents.id), "%Renegade \\d+",
				#keyPath(DataEvents.gameVersion), gameVersion.stringValue
			)
		}
	}

	/// Get all ids of a given type related to the event specified.
	public static func getAffectedIds<T: SimpleSerializedCoreDataStorable>(
		ofType type: T.Type,
		relatedToEvent event: Event,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [String] {
		let manager = manager ?? defaultManager
		var result: [String] = []
		autoreleasepool {
			result = manager.getAllTransformed(
				transformEntity: { $0.value(forKey: "id") as? String },
				alterFetchRequest: { (fetchRequest: NSFetchRequest<T.EntityType>) in
					fetchRequest.predicate = NSPredicate(
						format: "(ANY relatedEvents.id == %@)",
						event.id
					)
				}
			)
		}
		return result
	}
}
