//
//  DeletedRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/8/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

public struct DeletedRow: Codable {

// MARK: Properties

    public var source: String
    public var identifier: String

// MARK: Initialization

    public init(source: String, identifier: String) {
        self.source = source
        self.identifier = identifier
    }
}

// MARK: CodableCoreDataStorable
extension DeletedRow: CodableCoreDataStorable {

    /// (CodableCoreDataStorable Protocol)
    /// Type of the core data entity.
    public typealias EntityType = DeletedRows

    /// (CodableCoreDataStorable Protocol)
    /// Sets core data values to match struct values (specific).
    public func setAdditionalColumnsOnSave(
        coreItem: EntityType
    ) {
        // only save searchable columns
        coreItem.source = source
        coreItem.identifier = identifier
    }

    public func setIdentifyingPredicate(
        fetchRequest: NSFetchRequest<EntityType>
    ) {
        fetchRequest.predicate = NSPredicate(
            format: "(%K == %@ AND %K == %@)",
            #keyPath(DeletedRows.source), source,
            #keyPath(DeletedRows.identifier), identifier
        )
    }

}

// MARK: Faux CoreRowStorable
extension DeletedRow {

    /// Dunno why we need multiple statements of this, but whatevs:
    public typealias AlterFetchRequest<T: NSManagedObject> = ((NSFetchRequest<T>) -> Void)

    /// Delete the persistent store of this row.
    public static func delete(
        identifier: String,
        with manager: CodableCoreDataManageable? = nil
    ) -> Bool {
        return deleteAll(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(%K == %@)", #keyPath(DeletedRows.identifier), identifier)
        }
    }

    /// Delete the persistent store of all these rows.
    public static func deleteAll(
        identifiers: [String],
        with manager: CodableCoreDataManageable? = nil
    ) -> Bool {
        return deleteAll(with: manager) { fetchRequest in
            fetchRequest.predicate = NSPredicate(format: "(%K in %@)", #keyPath(DeletedRows.identifier), identifiers)
        }
    }
}

// MARK: CloudDataStorable
extension DeletedRow {

    /// Record identifier for this deleted row.
    public func getRecordId(recordName: String? = nil) -> CKRecordID {
        return CKRecordID(recordName: recordName ?? identifier, zoneID: GamesDataBackup.current.zoneId)
    }

    /// Returns all deleted rows waiting to be sent to the cloud for deletion there.
    public static func getAllDeletesToCloud(
        isFullDatabaseCopy: Bool,
        with manager: CodableCoreDataManageable?
    ) -> [CKRecordID] {
        guard !isFullDatabaseCopy else { return [] }
        let manager = manager ?? defaultManager
        let deletedRows = DeletedRow.getAll(with: manager)
        return deletedRows.map { $0.getRecordId(recordName: $0.identifier) }
    }
}

// MARK: Equatable
extension DeletedRow: Equatable {
    public static func == (_ lhs: DeletedRow, _ rhs: DeletedRow) -> Bool { // not true equality, just same db row
        return lhs.source == rhs.source && lhs.identifier == rhs.identifier
    }
}
