//
//  CoreDataMigration.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/10/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public struct CoreDataMigration {
    enum MigrationError: String, Error {
        case missingOriginalStore = "Original store not found"
        case incompatibleModels = "Incompatible models"
        case missingModels = "Model not found"
        case invalidJson = "File JSON was not valid"
    }

	public let fromBuild: Int
	public let loadMigration: (() -> CoreDataMigrationType)
	public init(fromBuild: Int, loadMigration: @escaping (() -> CoreDataMigrationType)) {
		self.fromBuild = fromBuild
		self.loadMigration = loadMigration
	}
}
