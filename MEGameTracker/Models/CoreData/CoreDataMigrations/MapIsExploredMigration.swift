//
//  MapIsExploredMigration.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/9/19.
//  Copyright © 2019 Emily Ivie. All rights reserved.
//

import Foundation

public struct MapIsExploredMigration: CoreDataMigrationType {
    public func run() {
        for gameId in getAllGameSequenceUuids() {
            guard let uuid = UUID(uuidString: gameId) else { continue }
            rewriteIsExplored(gameSequenceUuid: uuid)
        }
    }

    private func getAllGameSequenceUuids() -> [String] {
        return GameSequence.getAllIds()
    }

    private func rewriteIsExplored(gameSequenceUuid: UUID) {
        for map in Map.getAllExisting(gameSequenceUuid: gameSequenceUuid) {
            var map = map
            _ = map.save()
        }
    }
}
