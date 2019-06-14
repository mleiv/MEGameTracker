//
//  EventGameVersionMigration.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/13/19.
//  Copyright © 2019 Emily Ivie. All rights reserved.
//

import Foundation

public struct EventGameVersionMigration: CoreDataMigrationType {

    public func run() {
        for gameId in getAllGameSequenceUuids() {
            guard let uuid = UUID(uuidString: gameId) else { continue }
            let events = Event.getAllExisting(gameSequenceUuid: uuid)
            for event in events {
                var event = event
                _ = event.save()
            }
        }
    }

    private func getAllGameSequenceUuids() -> [String] {
        return GameSequence.getAllIds()
    }
}

