//
//  CoreAppData.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/31/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension App: CodableCoreDataStorable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = AppData

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {}

	public func setIdentifyingPredicate(fetchRequest: NSFetchRequest<EntityType>) {
		// none: there is only one row
	}

	/// Save if there were changes, cascade save if so specified, delay save to interval timer by default.
	public func saveAnyChanges(
		isCascadeChanges: EventDirection = .down,
		isAllowDelay: Bool = true,
		with manager: CodableCoreDataManageable? = nil
	) -> Bool {
		if hasUnsavedChanges {
			if isAllowDelay {
				hasUnsavedChanges = true
				return true // not an error
			} else {
				let isSaved = save(isCascadeChanges: isCascadeChanges, isAllowDelay: false, with: manager)
				return isSaved
			}
		}
		return true
	}

	/// Save the game value, cascade save if so specified, delaying for interval timer by default.
	public func save(
		isCascadeChanges: EventDirection,
		isAllowDelay: Bool,
		with manager: CodableCoreDataManageable?
	) -> Bool {
		hasUnsavedChanges = true // force this
		if isAllowDelay {
			hasUnsavedChanges = true
			return true // not an error
		}
		let manager = manager ?? defaultManager
		var isSaved = true
		if isCascadeChanges != .none && isCascadeChanges != .up {
			isSaved = isSaved && (game?.saveAnyChanges(
				isCascadeChanges: isCascadeChanges,
				isAllowDelay: isAllowDelay,
				with: manager
			) ?? false)
		}
		isSaved = isSaved && manager.saveValue(item: self)
		if isSaved {
			hasUnsavedChanges = false
		}
		return isSaved
	}

	/// Convenience version of save:isCascadeChanges:isAllowDelay:manager (no manager required)
	public func save(
		isCascadeChanges: EventDirection = .down,
		isAllowDelay: Bool
	) -> Bool {
		return save(isCascadeChanges: isCascadeChanges, isAllowDelay: isAllowDelay, with: nil)
	}

	/// (CodableCoreDataStorable Protocol override)
	public func save(
		with manager: CodableCoreDataManageable?
	) -> Bool {
		return save(isCascadeChanges: .down, isAllowDelay: true, with: manager)
	}

	/// Convenience - no isAllowDelay required
	public func save(
		isCascadeChanges: EventDirection,
		with manager: CodableCoreDataManageable? = nil
	) -> Bool {
		return save(isCascadeChanges: isCascadeChanges, isAllowDelay: true, with: manager)
	}

}
