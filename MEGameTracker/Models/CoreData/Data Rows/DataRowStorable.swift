//
//  DataRowStorable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/19/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

import CoreData

/// Shared properties and methods for all data entity values.
public protocol DataRowStorable: CodableCoreDataStorable {

// MARK: Required

    /// Unique Identifier
    var id: String { get }

// MARK: Optional

    /// Get an object by id.
    static func get(
        id: String,
        with manager: CodableCoreDataManageable?
    ) -> Self?

    /// Get a set of objects by id.
    static func getAll(
        ids: [String],
        with manager: CodableCoreDataManageable?
    ) -> [Self]

    /// Get the ids of any matching objects.
    static func getAllIds(
        with manager: CodableCoreDataManageable?,
        alterFetchRequest: @escaping AlterFetchRequest<EntityType>
    ) -> [String]

    /// Delete a set of objects by id.
    static func deleteAll(
        ids: [String],
        with manager: CodableCoreDataManageable?
    ) -> Bool

    /// Allow data to be issued a new id for migrations.
    mutating func migrateId(id newId: String)
}

extension DataRowStorable {

    /// The closure type for editing fetch requests.
    /// (Duplicate these per file or use Whole Module Optimization, which is slow in dev)
    public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

    /// (CodableCoreDataStorable Protocol)
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
        with manager: CodableCoreDataManageable?
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
        with manager: CodableCoreDataManageable?
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
        with manager: CodableCoreDataManageable?,
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
        with manager: CodableCoreDataManageable? = nil
    ) -> [String] {
        return getAllIds(with: manager) { _ in }
    }

    /// (Protocol default)
    /// Delete a set of objects by id.
    public static func deleteAll(
        ids: [String],
        with manager: CodableCoreDataManageable?
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
