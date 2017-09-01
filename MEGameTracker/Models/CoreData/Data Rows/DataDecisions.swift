//
//  DataDecisions.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/13/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CoreData

extension DataDecision: DataRowStorable {

	/// (CodableCoreDataStorable Protocol)
	/// Type of the core data entity.
	public typealias EntityType = DataDecisions

	/// (CodableCoreDataStorable Protocol)
	/// Sets core data values to match struct values (specific).
	public func setAdditionalColumnsOnSave(
		coreItem: EntityType
	) {
		// only save searchable columns
		coreItem.id = id
		coreItem.name = name
		coreItem.gameVersion = gameVersion.stringValue
	}
}
