//
//  CoreDataMigration.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/10/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public struct CoreDataMigration {
    
    public let fromBuild: Int
    public let loadMigration: (() -> CoreDataMigrationType)
    public init(fromBuild: Int, loadMigration: @escaping (() -> CoreDataMigrationType)) {
        self.fromBuild = fromBuild
        self.loadMigration = loadMigration
    }
}
