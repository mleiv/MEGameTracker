//
//  DataPersons.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation
import CoreData

extension DataPerson: DataRowStorable, DataEventsable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = DataPersons

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
		coreItem.id = id
		coreItem.name = name
		coreItem.personType = gameValues(key: "personType", defaultValue: "0")
		coreItem.isMaleLoveInterest = gameValues(key: "isMaleLoveInterest", defaultValue: "0")
		coreItem.isFemaleLoveInterest = gameValues(key: "isFemaleLoveInterest", defaultValue: "0")
		coreItem.relatedEvents = getRelatedDataEvents(context: coreItem.managedObjectContext)
	}

    /// (DataRowStorable Protocol)
    public mutating func migrateId(id newId: String) {
        id = newId
    }
}

extension DataPerson {

	/// The closure type for editing fetch requests.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

// MARK: Methods customized with GameVersion

    /// Retrieves a DataPerson matching an id, set to gameVersion.
    /// Leave gameVersion nil to get current gameVersion (recommended use).
	public static func get(
		id: String,
        gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil
	) -> DataPerson? {
		let one: DataPerson? = get(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(DataPersons.id), id
			)
		}
		return one
	}

    /// Retrieves a DataPerson matching some criteria, set to gameVersion.
    /// Leave gameVersion nil to get current gameVersion (recommended use).
	public static func get(
		gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> DataPerson? {
        let preferredGameVersion = gameVersion ?? App.current.gameVersion
		let one: DataPerson? = get(with: manager, alterFetchRequest: alterFetchRequest)
		return one?.changed(gameVersion: preferredGameVersion)
	}

    /// Retrieves multiple DataPersons matching some criteria, set to gameVersion.
    /// Leave gameVersion nil to get current gameVersion (recommended use).
	public static func getAll(
		gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [DataPerson] {
		let preferredGameVersion = gameVersion ?? App.current.gameVersion
		let all: [DataPerson] = getAll(with: manager, alterFetchRequest: alterFetchRequest)
		return all.map { $0.changed(gameVersion: preferredGameVersion) }
	}

	public mutating func delete(
		with manager: CodableCoreDataManageable? = nil
	) -> Bool {
		let manager = manager ?? defaultManager
		var isDeleted = true
		isDeleted = isDeleted && (photo?.delete() ?? true)
		isDeleted = isDeleted && (manager.deleteValue(item: self) )
		return isDeleted
	}
}
