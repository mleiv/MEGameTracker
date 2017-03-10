//
//  GameRowStorable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/8/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

/// Shared properties and methods for all game entity values.
///
/// Note: game get() methods are created from corresponding data rows, with game data only assigned if it exists.
///   - Use data entity queries rather than game entity.
///   - Use getExisting() to restrict to data rows with game values already set.
public protocol GameRowStorable: SimpleSerializedCoreDataStorable {

// MARK: Required

	/// Type of the core data entity.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	associatedtype EntityType: NSManagedObject

	/// Corresponding data entity for this game entity.
	associatedtype DataRowType: DataRowStorable

	/// Create a new game entity value for the game uuid given using the data value given.
	static func create(
		using data: DataRowType,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Self

	/// returns a game-specific object for the data object, if it exists, otherwise it creates one.
	static func getOrCreate(
		using data: DataRowType,
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Self?

	/// Identifier property.
	var id: String { get }

	/// Flag to indicate that there are changes pending a core data sync.
	var hasUnsavedChanges: Bool { get set }

	/// This value's game identifier.
	var gameSequenceUuid: String? { get set }

// MARK: Optional

	/// Flag the game as having changed when this value changes.
	/// (Default provided for GameModifying objects.)
	mutating func markGameChanged(
		with manager: SimpleSerializedCoreDataManageable?
	)

	/// Parses a cloud identifier into the parts needed to retrieve it from core data.
	static func parseIdentifyingName(
		name: String
	) -> ((id: String, gameSequenceUuid: String)?)

	/// Returns game-specific rows that exist.
	static func getExisting(
		id: String?,
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> Self?

	/// Returns game-specific rows that exist.
	static func getAllExisting(
		ids: [String],
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [Self]

	/// Return a game value made from the data value.
	static func get(
		id: String,
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Self?

	/// Return a game value made from the data value.
	static func getFromData(
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> Self?

	/// Return all matching game values made from the data values.
	static func getAll(
		ids: [String],
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?
	) -> [Self]

	/// Return all matching game values made from the data values.
	static func getAllFromData(
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> [Self]

	/// Check if the game value has any changes before trying to save it.
	mutating func saveAnyChanges(
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool

	/// Save the game value.
	mutating func save(
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool

	/// Delete the game value.
	static func delete(
		id: String,
		gameSequenceUuid uuid: String,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool

	/// Delete all the matching game values.
	static func deleteAll(
		gameSequenceUuid uuid: String,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool

	/// Remove any game rows missing their data rows.
	static func deleteOrphans(
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool
}

extension GameRowStorable {

	/// The closure type for editing fetch requests.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Alters the predicate to retrieve only the row equal to this object.
	public func setIdentifyingPredicate(
		fetchRequest: NSFetchRequest<EntityType>
	) {
		fetchRequest.predicate = NSPredicate(
			format: "(id = %@ AND gameSequenceUuid = %@)",
			id,
			gameSequenceUuid ?? (App.current.game?.uuid ?? "")
		)
	}

	/// (Protocol default)
	/// Initializes value type from core data object with serialized data.
	public static func getOrCreate(
		using data: DataRowType,
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Self? {
		var one: Self = create(using: data, with: manager)
		one.gameSequenceUuid = gameSequenceUuid ?? one.gameSequenceUuid
		do {
			// get game-specific data if it exists
			if let data: Data = manager?.getOneTransformed(
				transformEntity: { coreEntity -> Data? in
					coreEntity.value(forKey: Self.serializedDataKey) as? Data
				}, alterFetchRequest: { fetchRequest in
					one.setIdentifyingPredicate(fetchRequest: fetchRequest)
				}
			) {
				one.setData(try SerializableData(serializedData: data))
			}
		} catch {}
		return one
	}

	/// Convenience version on getOrCreate:data:gameSequenceUuid:manager (no gameSequenceUuid)
	public static func getOrCreate(
		using data: DataRowType,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Self? {
		return getOrCreate(using: data, gameSequenceUuid: nil, with: manager)
	}

// MARK: Remove Default Get

	/// (SimpleSerializedCoreDataStorable Protocol override)
	/// Gets the struct to match the core data request.
	public static func get(
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> Self? {
		fatalError("You can't run this in GameRowStorable - use getFromData or getExisting")
	}

	/// (SimpleSerializedCoreDataStorable Protocol override)
	/// Convenience version of get:manager:alterFetchRequest (no alterFetchRequest required).
	public static func get(
		with manager: SimpleSerializedCoreDataManageable? = nil
		// can't use alterFetchRequest here - they have different types
	) -> Self? {
		return getFromData(gameSequenceUuid: nil, with: manager) { _ in }
	}

	/// (SimpleSerializedCoreDataStorable Protocol override)
	/// Gets all structs that match the core data request.
	public static func getAll(
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [Self] {
		fatalError("You can't run this in GameRowStorable - use getAllFromData or getAllExisting")
	}

	/// (SimpleSerializedCoreDataStorable Protocol override)
	/// Convenience version of getAll:manager:alterFetchRequest (no alterFetchRequest required).
	public static func getAll(
		with manager: SimpleSerializedCoreDataManageable? = nil
		// can't use alterFetchRequest here - they have different types
	) -> [Self] {
		return getAllFromData(gameSequenceUuid: nil, with: manager) { _ in }
	}

// MARK: Get Existing Only

	/// (Protocol default)
	/// Returns game-specific rows that exist.
	public static func getExisting(
		id: String?,
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> Self? {
		let ids: [String] = [id].flatMap { $0 }
		return getAllExisting(
			ids: ids,
			gameSequenceUuid: gameSequenceUuid,
			with: manager,
			alterFetchRequest: alterFetchRequest
		).first
	}

	/// Convenience version of getExisting:id:gameSequenceUuid:manager:alterFetchRequest 
	///	(no id, manager, alterFetchRequest required).
	public static func getExisting(
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType> = { _ in }
	) -> Self? {
		return getExisting(
			id: nil,
			gameSequenceUuid: gameSequenceUuid,
			with: manager,
			alterFetchRequest: alterFetchRequest
		)
	}

	/// Convenience version of getExisting:id:gameSequenceUuid:manager:alterFetchRequest 
	///	(no manager, alterFetchRequest required).
	public static func getExisting(
		id: String?,
		gameSequenceUuid: String? = nil,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> Self? {
		return getExisting(id: id, gameSequenceUuid: gameSequenceUuid, with: manager) { _ in }
	}

	/// (Protocol default)
	/// Returns game-specific rows that exist.
	public static func getAllExisting(
		ids: [String],
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [Self] {
		let manager = manager ?? defaultManager
		var some: [Self] = []
		autoreleasepool {
			some = manager.getAllTransformed(
				transformEntity: { (coreItem: EntityType) -> Self? in
					guard let id = coreItem.value(forKey: "id") as? String,
						let generalData = DataRowType.get(id: id, with: manager)
					else { return nil }
					var one: Self = create(using: generalData, with: manager)
					if let jsonData = coreItem.value(forKey: serializedDataKey) as? Data,
						let data = try? SerializableData(jsonData: jsonData) {
						one.setData(data)
					}
					return one
				},
				alterFetchRequest: { fetchRequest in
					if let gameSequenceUuid = gameSequenceUuid {
						fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid == %@)", gameSequenceUuid)
					}
					if !ids.isEmpty {
						fetchRequest.predicate = NSPredicate(format: "(id in %@)", ids)
					}
					alterFetchRequest(fetchRequest)
				}
			)
		}
		return some
	}

	/// Convenience version of getAllExisting:ids:gameSequenceUuid:manager:alterFetchRequest 
	///	(no id, manager, alterFetchRequest required).
	public static func getAllExisting(
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType> = { _ in }
	) -> [Self] {
		return getAllExisting(
			ids: [],
			gameSequenceUuid: gameSequenceUuid,
			with: manager,
			alterFetchRequest: alterFetchRequest
		)
	}

	/// Convenience version of getAllExisting:id:gameSequenceUuid:manager:alterFetchRequest 
	///	(no manager, alterFetchRequest required).
	public static func getAllExisting(
		ids: [String],
		gameSequenceUuid: String? = nil,
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [Self] {
		return getAllExisting(ids: ids, gameSequenceUuid: gameSequenceUuid, with: manager) { _ in }
	}

	/// Convenience version of getAllExisting:id:gameSequenceUuid:manager:alterFetchRequest 
	///	(no manager, parameters required).
	public static func getAllExisting(
		with manager: SimpleSerializedCoreDataManageable? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType> = { _ in }
	) -> [Self] {
		return getAllExisting(ids: [], gameSequenceUuid: nil, with: manager, alterFetchRequest: alterFetchRequest)
	}

// MARK: Get or Create From Data

	/// (Protocol default)
	/// Return a game value made from the data value.
	public static func get(
		id: String,
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Self? {
		return getFromData(gameSequenceUuid: gameSequenceUuid, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(id == %@)", id)
		}
	}

	/// Convenience version of get:id:gameSequenceUuid:manager (no gameSequenceUuid required).
	public static func get(
		id: String,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Self? {
		return get(id: id, gameSequenceUuid: nil, with: manager)
	}

	/// Convenience version of get:id:gameSequenceUuid:manager (no manager required).
	public static func get(
		id: String,
		gameSequenceUuid: String? = nil
	) -> Self? {
		return get(id: id, gameSequenceUuid: gameSequenceUuid, with: nil)
	}

	/// (Protocol default)
	/// Return a game value made from the data value.
	public static func getFromData(
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> Self? {
		return getAllFromData(
			gameSequenceUuid: gameSequenceUuid,
			with: manager,
			alterFetchRequest: alterFetchRequest
		).first
	}

	/// Convenience version of getFromData:gameSequenceUuid:manager:alterFetchRequest (no manager required).
	public static func getFromData(
		gameSequenceUuid: String? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> Self? {
		return getFromData(gameSequenceUuid: gameSequenceUuid, with: nil, alterFetchRequest: alterFetchRequest)
	}

	/// (Protocol default)
	/// Return all matching game values made from the data values.
	public static func getAll(
		ids: [String],
		gameSequenceUuid: String? = nil,
		with manager: SimpleSerializedCoreDataManageable?
	) -> [Self] {
		let all: [Self] = getAllFromData(gameSequenceUuid: gameSequenceUuid, with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(id in %@)", ids)
		}
		return all
	}

	/// Convenience version of getAll:ids:gameSequenceUuid:manager (no manager required).
	public static func getAll(
		ids: [String],
		gameSequenceUuid: String? = nil
	) -> [Self] {
		return getAll(ids: ids, gameSequenceUuid: gameSequenceUuid, with: nil)
	}

	/// Convenience version of getAll:ids:gameSequenceUuid:manager (no gameSequenceUuid required).
	public static func getAll(
		ids: [String],
		with manager: SimpleSerializedCoreDataManageable?
	) -> [Self] {
		return getAll(ids: ids, gameSequenceUuid: nil, with: manager)
	}

	/// (Protocol default)
	/// Return all matching game values made from the data values.
	public static func getAllFromData(
		gameSequenceUuid: String?,
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> [Self] {
		let manager = manager ?? defaultManager
		let dataItems = DataRowType.getAll(with: manager, alterFetchRequest: alterFetchRequest)
		let some: [Self] = dataItems.flatMap { (dataItem: DataRowType) -> Self? in
			Self.getOrCreate(using: dataItem, gameSequenceUuid: gameSequenceUuid, with: manager)
		}
		return some
	}

	/// Convenience version of getAllFromData:gameSequenceUuid:manager:alterFetchRequest (no gameSequenceUuid required).
	public static func getAllFromData(
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType>
	) -> [Self] {
		return getAllFromData(gameSequenceUuid: nil, with: nil, alterFetchRequest: alterFetchRequest)
	}

	/// Convenience version of getAllFromData:gameSequenceUuid:manager:alterFetchRequest (no manager required).
	public static func getAllFromData(
		gameSequenceUuid: String? = nil,
		alterFetchRequest: @escaping AlterFetchRequest<DataRowType.EntityType> = { _ in }
	) -> [Self] {
		return getAllFromData(gameSequenceUuid: gameSequenceUuid, with: nil, alterFetchRequest: alterFetchRequest)
	}

// MARK: Save

	/// (Protocol default)
	/// Check if the game value has any changes before trying to save it.
	public mutating func saveAnyChanges(
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		if hasUnsavedChanges {
			let isSaved = save(with: manager)
			return isSaved
		}
		return true
	}

	/// Convenience version of saveAnyChanges:manager (no manager required).
	public mutating func saveAnyChanges() -> Bool {
		return saveAnyChanges(with: nil)
	}

	/// (Protocol default)
	/// Save the game value.
	public mutating func save( // override to mark game sequence changed also
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		guard gameSequenceUuid?.isEmpty == false else { return false }
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

	/// (Protocol default)
	/// Delete the game value.
	public static func delete(
		id: String,
		gameSequenceUuid uuid: String,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		return deleteAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(id == %@ AND gameSequenceUuid == %@)", id, uuid)
		}
	}

	/// Convenience version of delete:id:gameSequenceUuid:manager (no manager required).
	public static func delete(
		id: String,
		gameSequenceUuid uuid: String
	) -> Bool {
		return delete(id: id, gameSequenceUuid: uuid, with: nil)
	}

	/// (Protocol default)
	/// Delete all the matching game values.
	public static func deleteAll(
		gameSequenceUuid uuid: String,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		return deleteAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(gameSequenceUuid == %@)", uuid)
		}
	}

	/// Convenience version of deleteAll:gameSequenceUuid:manager (no manager required).
	public static func deleteAll(
		gameSequenceUuid uuid: String
	) -> Bool {
		return deleteAll(gameSequenceUuid: uuid, with: nil)
	}

	/// (Protocol default)
	/// Remove any game rows missing their data rows.
	public static func deleteOrphans(
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		return deleteAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(dataParent == nil)")
		}
	}

	/// Convenience version of deleteOrphans:manager (no parameters required).
	public static func deleteOrphans() -> Bool {
		return deleteOrphans(with: nil)
	}
}
