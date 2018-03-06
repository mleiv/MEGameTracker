//
//  EventTriggerMigration.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/2/18.
//  Copyright © 2018 Emily Ivie. All rights reserved.
//

import Foundation

public struct EventTriggerMigration: CoreDataMigrationType {

    public func run() {
        for gameId in getAllGameSequenceUuids() {
            guard let uuid = UUID(uuidString: gameId) else { continue }
            triggerMissionEvents(gameSequenceUuid: uuid)
            triggerItemEvents(gameSequenceUuid: uuid)
            triggerDecisionEvents(gameSequenceUuid: uuid)
        }
    }

    private func getAllGameSequenceUuids() -> [String] {
        return GameSequence.getAllIds()
    }

    private func triggerMissionEvents(gameSequenceUuid: UUID) {
        for mission in Mission.getAllExisting(gameSequenceUuid: gameSequenceUuid) {
            for event in mission.events {
                guard event.type == .triggers && event.isTriggered != mission.isCompleted
                    else { continue }
                var event2 = event.changed(
                    isTriggered: mission.isCompleted,
                    isSave: false,
                    isNotify: false
                )
                event2?.triggeredDate = mission.completedDate
                event2?.markChanged()
                event2?.notifySaveToCloud(fields: [
                    "isTriggered": mission.isCompleted,
                    "triggeredDate": mission.completedDate
                    ])
                _ = event2?.save()
            }
        }
    }

    private func triggerItemEvents(gameSequenceUuid: UUID) {
        for item in Item.getAllExisting(gameSequenceUuid: gameSequenceUuid) {
            for event in item.events {
                guard event.type == .triggers && event.isTriggered != item.isAcquired
                    else { continue }
                var event2 = event.changed(
                    isTriggered: item.isAcquired,
                    isSave: false,
                    isNotify: false
                )
                event2?.triggeredDate = item.acquiredDate
                event2?.markChanged()
                event2?.notifySaveToCloud(fields: [
                    "isTriggered": item.isAcquired,
                    "triggeredDate": item.acquiredDate
                ])
                _ = event2?.save()
            }
        }
    }

    private func triggerDecisionEvents(gameSequenceUuid: UUID) {
        for decision in Decision.getAllExisting(gameSequenceUuid: gameSequenceUuid) {
            for eventId in decision.linkedEventIds {
                guard let event = Event.get(id: eventId)
                    else { continue }
                var event2 = event.changed(
                    isTriggered: decision.isSelected,
                    isSave: false,
                    isNotify: false
                )
                event2?.triggeredDate = decision.selectedDate
                event2?.markChanged()
                event2?.notifySaveToCloud(fields: [
                    "isTriggered": decision.isSelected,
                    "triggeredDate": decision.selectedDate
                    ])
                _ = event2?.save()
            }
        }
    }
}
