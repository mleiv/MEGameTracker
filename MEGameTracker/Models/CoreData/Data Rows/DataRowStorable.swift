//
//  DataRowStorable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/8/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

/// Shared properties and methods for all data entity values.
public protocol DataRowStorable: SimpleSerializedCoreDataStorable {

// MARK: Required

	/// Type of the core data entity.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	associatedtype EntityType: NSManagedObject

	/// Identifier property.
	var id: String { get }

// MARK: Optional

	/// Get an object by id.
	static func get(
		id: String,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Self?

	/// Get a set of objects by id.
	static func getAll(
		ids: [String],
		with manager: SimpleSerializedCoreDataManageable?
	) -> [Self]

	/// Get the ids of any matching objects.
	static func getAllIds(
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [String]

	/// Delete a set of objects by id.
	static func deleteAll(
		ids: [String],
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool
}

extension DataRowStorable {

	/// The closure type for editing fetch requests.
	/// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
	public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

	/// (SimpleSerializedCoreDataStorable Protocol)
	/// Alters the predicate to retrieve only the row equal to this object.
	public func setIdentifyingPredicate(
		fetchRequest: NSFetchRequest<EntityType>
	) {
		fetchRequest.predicate = NSPredicate(format: "(id == %@)", id)
	}

	/// (Protocol default)
	/// Get an object by id.
	public static func get(
		id: String,
		with manager: SimpleSerializedCoreDataManageable?
	) -> Self? {
		return get(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(id == %@)", id)
		}
	}

	/// Convenience version of get:id:manager (no manager required).
	public static func get(
		id: String
	) -> Self? {
		return get(id: id, with: nil)
	}

	/// (Protocol default)
	/// Get a set of objects by id.
	public static func getAll(
		ids: [String],
		with manager: SimpleSerializedCoreDataManageable?
	) -> [Self] {
		return getAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(id in %@)", ids)
		}
	}

	/// Convenience version of getAll:ids:manager (no manager required).
	public static func getAll(
		ids: [String]
	) -> [Self] {
		return getAll(ids: ids, with: nil)
	}

	/// (Protocol default)
	/// Get the ids of any matching objects.
	public static func getAllIds(
		with manager: SimpleSerializedCoreDataManageable?,
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [String] {
		let manager = manager ?? defaultManager
		var result: [String] = []
		autoreleasepool {
			result = manager.getAllTransformed(
				transformEntity: { $0.value(forKey: "id") as? String },
				alterFetchRequest: alterFetchRequest
			)
		}
		return result
	}

	/// Convenience version of getAllIds:manager:alterFetchRequest (no manager required).
	public static func getAllIds(
		alterFetchRequest: @escaping AlterFetchRequest<EntityType>
	) -> [String] {
		return getAllIds(with: nil, alterFetchRequest: alterFetchRequest)
	}

	/// Convenience version of getAllIds:manager:alterFetchRequest (no parameters required).
	public static func getAllIds(
		with manager: SimpleSerializedCoreDataManageable? = nil
	) -> [String] {
		return getAllIds(with: manager) { _ in }
	}

	/// (Protocol default)
	/// Delete a set of objects by id.
	public static func deleteAll(
		ids: [String],
		with manager: SimpleSerializedCoreDataManageable?
	) -> Bool {
		return deleteAll(with: manager) { fetchRequest in
			fetchRequest.predicate = NSPredicate(format: "(id in %@)", ids)
		}
	}

	/// Convenience version of deleteAll:ids:manager (no manager required).
	public static func deleteAll(
		ids: [String]
	) -> Bool {
		return deleteAll(ids: ids, with: nil)
	}
}
