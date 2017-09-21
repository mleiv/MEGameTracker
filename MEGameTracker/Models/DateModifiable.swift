//
//  DateModifiable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/7/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// Describes date properties in conforming objects.
public protocol DateModifiable {

	/// Flag to indicate that there are changes pending a core data sync.
	var hasUnsavedChanges: Bool { get set }

	/// Date when value was created.
	var createdDate: Date { get set }

	/// Date when value was last changed.
	var modifiedDate: Date { get set }

    /// A copy of the unchanged data from the database, for faster saving.
    /// Reset to nil on any changes.
	var rawData: Data? { get set }
}
extension DateModifiable {
    /// Update modifiedDate to now.
    public mutating func touch() {
        guard !GamesDataBackup.current.isSyncing else { return } // TODO: does not belong here
        modifiedDate = Date()
    }

    /// Mark hasUnsavedChanges true and update modifiedDate to now.
    public mutating func markChanged() {
        rawData = nil
        touch()
        hasUnsavedChanges = true
    }
}

// MARK: Serializable Utilities
extension DateModifiable {
    /// Fetch DateModifiable values from a remote dictionary.
    public mutating func unserializeDateModifiableData(_ data: [String: Any?]) {
        createdDate = data["createdDate"] as? Date ?? createdDate
        modifiedDate = data["modifiedDate"] as? Date ?? modifiedDate
    }
}
extension DateModifiable where Self: Codable {
	/// Fetch DateModifiable values from a Codable dictionary.
	public mutating func unserializeDateModifiableData(decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DateModifiableCodingKeys.self)
        createdDate = (try container.decodeIfPresent(Date.self, forKey: .createdDate)) ?? Date()
        modifiedDate = (try container.decodeIfPresent(Date.self, forKey: .modifiedDate)) ?? Date()
    }
    /// Store DateModifiable values to a Codable dictionary.
    public func serializeDateModifiableData(encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DateModifiableCodingKeys.self)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(modifiedDate, forKey: .modifiedDate)
    }
}

extension DateModifiable where Self: CodableCoreDataStorable {
    /// Save DateModifiable values to Core Data
	public func setDateModifiableColumnsOnSave(coreItem: EntityType) {
		coreItem.setValue(createdDate, forKey: "createdDate")
		coreItem.setValue(modifiedDate, forKey: "modifiedDate")
	}
}

/// Codable keys for objects adhering to DateModifiable
public enum DateModifiableCodingKeys: String, CodingKey {
    case createdDate
    case modifiedDate
}
