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

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = DataPersons

	/// (SimpleSerializedCoreDataStorable Protocol)
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
}

extension DataPerson {

	/// The closure type for editing fetch requests.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

	public static func get(
		id: String,
		gameVersion: GameVersion?,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> DataPerson? {
		let one: DataPerson? = get(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(DataPersons.id), id
			)
		}
		return one
	}

	public static func get(
		gameVersion: GameVersion?,
		with manager: SimpleSerializedCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> DataPerson? {
		let preferredGameVersion = gameVersion ?? (App.current.game?.gameVersion ?? .game1)
		var one: DataPerson? = get(with: manager, alterFetchRequest: alterFetchRequest)
		one?.change(gameVersion: preferredGameVersion)
		return one
	}

	public static func getAll(
		gameVersion: GameVersion?,
		with manager: SimpleSerializedCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [DataPerson] {
		let preferredGameVersion = gameVersion ?? (App.current.game?.gameVersion ?? .game1)
		var all: [DataPerson] = getAll(with: manager, alterFetchRequest: alterFetchRequest)
		for i in 0..<all.count { all[i].change(gameVersion: preferredGameVersion) }
		return all
	}

	public mutating func delete(
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Bool {
		let manager = manager ?? defaultManager
		var isDeleted = true
		isDeleted = isDeleted && (photo?.delete() ?? true)
		isDeleted = isDeleted && (manager.deleteValue(item: self) )
		return isDeleted
	}
}
