//
//  GameMaps.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension Map: GameRowStorable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GameMaps

	/// (GameRowStorable Protocol)
	/// Corresponding data entity for this game entity.
	public typealias DataRowType = DataMap

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
        setDateModifiableColumnsOnSave(coreItem: coreItem) //TODO
		coreItem.id = id
		coreItem.gameSequenceUuid = gameSequenceUuid?.uuidString
		coreItem.isExplored = isExplored ? 1 : 0
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
		coreItem.dataParent = generalData.entity(context: coreItem.managedObjectContext)
	}

	/// (GameRowStorable X Eventsable Protocol)
	/// Create a new game entity value for the game uuid given using the data value given.
	public static func create(
		using data: DataRowType,
		with manager: CodableCoreDataManageable?
	) -> Map {
		var item = Map(id: data.id, generalData: data)
		item.events = item.getEvents(gameSequenceUuid: item.gameSequenceUuid, with: manager)
		return item
	}

    /// (GameRowStorable Protocol)
    public mutating func migrateId(id newId: String) {
        id = newId
        generalData.migrateId(id: newId)
    }
}

extension Map {

	/// The closure type for editing fetch requests.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

    /// (OVERRIDE)
    /// Return all matching game values made from the data values.
    public static func getAllFromData(
        gameSequenceUuid: UUID?,
        with manager: CodableCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
    ) -> [Map] {
        let manager = manager ?? defaultManager
        let dataItems = DataRowType.getAll(gameVersion: nil, with: manager, alterFetchRequest: alterFetchRequest)
        let some: [Map] = dataItems.map { (dataItem: DataRowType) -> Map? in
            Map.getOrCreate(using: dataItem, gameSequenceUuid: gameSequenceUuid, with: manager)
        }.filter({ $0 != nil }).map({ $0! })
        return some
    }

// MARK: Methods customized with GameVersion

	/// Get a map by id and set it to specified game version.
	public static func get(
		id: String,
        gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> Map? {
		return getFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(DataMaps.id), id
			)
		}
	}

	/// Get a map and set it to specified game version.
	public static func getFromData(
		gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> Map? {
		return getAllFromData(gameVersion: gameVersion, with: manager, alterFetchRequest: alterFetchRequest).first
	}

	/// Get a set of maps with the specified ids and set them to specified game version.
	public static func getAll(
		ids: [String],
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Map] {
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K in %@)",
				#keyPath(DataMaps.id), ids
			)
		}
	}

	/// Get a set of maps and set them to specified game version.
	public static func getAllFromData(
		gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> [Map] {
		let manager = manager ?? defaultManager
		let dataItems = DataRowType.getAll(gameVersion: gameVersion, with: manager, alterFetchRequest: alterFetchRequest)
		let some: [Map] = dataItems.map { (dataItem: DataRowType) -> Map? in
			Map.getOrCreate(using: dataItem, with: manager)
		}.filter({ $0 != nil }).map({ $0! })
		return some
	}

// MARK: Additional Convenience Methods

	/// Get all maps from the specified game version.
	public static func getAll(
		gameVersion: GameVersion,
		with manager: CodableCoreDataManageable? = nil
	) -> [Map] {
		return getAllFromData(gameVersion: gameVersion, with: manager) { _ in }
	}

	/// Get all child maps of the specified map.
	public static func getAll(
		inMapId mapId: String,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Map] {
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				#keyPath(DataMaps.inMapId), mapId
			)
		}
	}

	/// Get all main maps.
	public static func getAllMain(
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Map] {
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == true)",
				#keyPath(DataMaps.isMain)
			)
		}
	}

	/// Get all recently viewed maps.
	public static func getAllRecent(
        gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Map] {
		var maps: [Map] = []
		App.current.recentlyViewedMaps.contents.forEach {
			if var map = Map.get(id: $0.id, gameVersion: gameVersion, with: manager) {
				map.modifiedDate = $0.date // hijack for date - won't be saved anyway
				maps.append(map)
			}
		}
		return maps
	}
}
