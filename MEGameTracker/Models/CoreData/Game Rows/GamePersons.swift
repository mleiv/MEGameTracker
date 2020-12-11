//
//  GamePersons.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import Foundation
import CoreData

extension Person: GameRowStorable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = GamePersons

	/// (GameRowStorable Protocol)
	/// Corresponding data entity for this game entity.
	public typealias DataRowType = DataPerson

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
        setDateModifiableColumnsOnSave(coreItem: coreItem) //TODO
		coreItem.id = id
		coreItem.gameSequenceUuid = gameSequenceUuid?.uuidString
		coreItem.isSavedToCloud = isSavedToCloud ? 1 : 0
		coreItem.dataParent = generalData.entity(context: coreItem.managedObjectContext)
	}

	/// (GameRowStorable X Eventsable Protocol)
	/// Create a new game entity value for the game uuid given using the data value given.
	public static func create(
		using data: DataRowType,
		with manager: CodableCoreDataManageable?
	) -> Person {
		var item = Person(id: data.id, generalData: data)
		item.events = item.getEvents(gameSequenceUuid: item.gameSequenceUuid, with: manager)
		return item
	}

    /// (GameRowStorable Protocol)
    public mutating func migrateId(id newId: String) {
        id = newId
        generalData.migrateId(id: newId)
    }
}

extension Person {

	/// The closure type for editing fetch requests.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

	/// We store the different game version values in one column. 
	/// This creates a search string for one specific version value.
	internal static func valueForGame(_ value: String, _ gameVersion: GameVersion? = nil) -> String {
		if let gameVersion = gameVersion {
			switch gameVersion {
			case .game1: return "|\(value)|*|*|"
			case .game2: return "|*|\(value)|*|"
			case .game3: return "|*|*|\(value)|"
			}
		}
		return "*|\(value)|*"
	}

    /// (OVERRIDE)
    /// Return all matching game values made from the data values.
    public static func getAllFromData(
        gameSequenceUuid: UUID?,
        with manager: CodableCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
    ) -> [Person] {
        let manager = manager ?? defaultManager
        let dataItems = DataRowType.getAll(gameVersion: nil, with: manager, alterFetchRequest: alterFetchRequest)
        let some: [Person] = dataItems.map { (dataItem: DataRowType) -> Person? in
            Person.getOrCreate(using: dataItem, gameSequenceUuid: gameSequenceUuid, with: manager)
        }.filter({ $0 != nil }).map({ $0! })
        return some
    }

// MARK: Methods customized with GameVersion

	/// Get a person by id and set it to specified game version.
	public static func get(
		id: String,
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> Person? {
		return getFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K == %@)",
				"id", id
			)
		}
	}

	/// Get a person and set it to specified game version.
	public static func getFromData(
		gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> Person? {
		return getAllFromData(gameVersion: gameVersion, with: manager, alterFetchRequest: alterFetchRequest).first
	}

	/// Get a set of persons with the specified ids and set them to specified game version.
	public static func getAll(
		ids: [String],
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Person] {
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K in %@)",
				"id", ids
			)
		}
	}

	/// Get a set of persons and set them to specified game version.
	public static func getAllFromData(
        gameVersion: GameVersion?,
		with manager: CodableCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> [Person] {
		let manager = manager ?? defaultManager
		let dataItems = DataRowType.getAll(gameVersion: gameVersion, with: manager, alterFetchRequest: alterFetchRequest)
		let some: [Person] = dataItems.map { (dataItem: DataRowType) -> Person? in
			Person.getOrCreate(using: dataItem, with: manager)
		}.filter({ $0 != nil }).map({ $0! })
		return some
	}

// MARK: Additional Convenience Methods

	/// Get a person matching the name specified, and set it to specified game version.
	public static func get(
		name: String,
        gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> Person? {
        // not like the others, fetches all from all games
		return getFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K LIKE[cd] %@)",
				#keyPath(DataPersons.name), name
			)
		}
	}

	/// Get all persons matching the name specified, and set them to specified game version.
	public static func getAll(
		likeName name: String,
		limit: Int = App.current.searchMaxResults,
        gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Person] {
        // not like the others, fetches all from all games
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K CONTAINS[cd] %@)",
				#keyPath(DataPersons.name), name
			)
			fetchRequest.fetchLimit = limit
		}
	}

	/// Get all Squad-type persons from the specified game version.
	public static func getAllTeam(
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Person] {
        let gameVersion = gameVersion ?? App.current.gameVersion
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K LIKE %@)",
				#keyPath(DataPersons.personType), valueForGame("squad", gameVersion)
			)
		}
	}

	/// Get all Associate-type persons from the specified game version.
	public static func getAllAssociates(
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Person] {
        let gameVersion = gameVersion ?? App.current.gameVersion
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K LIKE %@)",
				#keyPath(DataPersons.personType), valueForGame("associate", gameVersion)
			)
		}
	}

	/// Get all Enemy-type persons from the specified game version.
	public static func getAllEnemies(
		gameVersion: GameVersion? = nil,
		with manager: CodableCoreDataManageable? = nil
	) -> [Person] {
        let gameVersion = gameVersion ?? App.current.gameVersion
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K LIKE %@)",
				#keyPath(DataPersons.personType), valueForGame("enemy", gameVersion)
			)
		}
	}

	/// Get all available love interests from the specified game version.
	public static func getAllLoveOptions(
		gameVersion: GameVersion? = nil,
		isMale: Bool = true,
		with manager: CodableCoreDataManageable? = nil
	) -> [Person] {
        let gameVersion = gameVersion ?? App.current.gameVersion
		return getAllFromData(gameVersion: gameVersion, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(
				format: "(%K LIKE %@)",
				isMale ? #keyPath(DataPersons.isMaleLoveInterest) : #keyPath(DataPersons.isFemaleLoveInterest),
				valueForGame("1", gameVersion)
			)
		}
	}
}
