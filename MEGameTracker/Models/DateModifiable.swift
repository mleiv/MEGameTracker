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
}

// MARK: Serializable Utilities
extension DateModifiable where Self: SerializedDataStorable, Self: SerializedDataRetrievable {

	/// Save DateModifiable values to a SerializedData dictionary.
	public func serializeDateModifiableData(
		list: [String: SerializedDataStorable?]
	) -> [String: SerializedDataStorable?] {
		var list = list
		list["createdDate"] = createdDate
		list["modifiedDate"] = modifiedDate
		return list
	}

	/// Fetch DateModifiable values from a SerializedData dictionary.
	public mutating func unserializeDateModifiableData(data: SerializableData) {
		createdDate = data["createdDate"]?.date ?? createdDate
		modifiedDate = data["modifiedDate"]?.date ?? modifiedDate
	}
}

// MARK: Serializable Utilities
extension DateModifiable where Self: SimpleSerializedCoreDataStorable {
	public func setDateModifiableColumnsOnSave(coreItem: EntityType) {
		coreItem.setValue(createdDate, forKey: "createdDate")
		coreItem.setValue(modifiedDate, forKey: "modifiedDate")
	}
}

extension DateModifiable {

	public mutating func touch() {
		guard !GamesDataBackup.current.isSyncing else { return }
		modifiedDate = Date()
	}

	public mutating func markChanged() {
		touch()
		hasUnsavedChanges = true
	}
}
