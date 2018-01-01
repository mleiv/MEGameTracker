//
//  DataMap.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension DataMap: DataRowStorable, DataEventsable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = DataMaps

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
		coreItem.id = id
		coreItem.name = name
		coreItem.inMapId = inMapId
		coreItem.isShowInList = isShowInList ? 1: 0
		coreItem.isMain = isMain ? 1 : 0
		coreItem.relatedEvents = getRelatedDataEvents(context: coreItem.managedObjectContext)
	}

    /// (DataRowStorable Protocol)
    public mutating func migrateId(id newId: String) {
        id = newId
    }
}

extension DataMap {

	/// The closure type for editing fetch requests.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

// MARK: Methods customized with GameVersion

    /// Retrieves a DataMap matching an id, set to gameVersion.
    /// Leave gameVersion nil to get current gameVersion (recommended use).
	public static func get(
		id: String,
		gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil
	) -> DataMap? {
		let one: DataMap? = get(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(DataMaps.id), id
			)
		}
		return one
	}

    /// Retrieves a DataMap matching some criteria, set to gameVersion.
    /// Leave gameVersion nil to get current gameVersion (recommended use).
	public static func get(
		gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> DataMap? {
        let preferredGameVersion = gameVersion ?? (App.current.game?.gameVersion ?? .game1)
		let one: DataMap? = get(with: manager, alterFetchRequest: alterFetchRequest)
        return one?.changed(gameVersion: preferredGameVersion)
	}

    /// Retrieves multiple DataMaps matching some criteria, set to gameVersion.
    /// Leave gameVersion nil to get current gameVersion (recommended use).
	public static func getAll(
		gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [DataMap] {
        let preferredGameVersion = gameVersion ?? (App.current.game?.gameVersion ?? .game1)
		let all: [DataMap] = getAll(with: manager, alterFetchRequest: alterFetchRequest)
        return all.map { $0.changed(gameVersion: preferredGameVersion) }
	}
}
