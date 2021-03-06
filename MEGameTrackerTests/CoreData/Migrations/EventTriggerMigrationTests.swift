//
//  EventTriggerMigrationTests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 3/4/18.
//  Copyright © 2018 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class EventTriggerMigrationTests: MEGameTrackerTests {

    let mission1Data = """
{
    "id": "Mission 1",
    "name": "Mission 1",
    "gameVersion": "1",
    "missionType": "Assignment",
    "events": [{
        "type": "Triggers",
        "id": "Mission Event"
    }]
}
"""
    let mission2Data = """
{
    "id": "Mission 2",
    "name": "Mission 2",
    "gameVersion": "1",
    "missionType": "Assignment",
    "events": [{
        "type": "BlockedUntil",
        "id": "Mission Event"
    }]
}
"""
    let missionEventData = """
{
    "id": "Mission Event",
    "gameVersion": "1"
}
"""

    let item1Data = """
{
    "id": "Item 1",
    "name": "Item 1",
    "gameVersion": "1",
    "itemType": "Loot",
    "itemDisplayType": "Loot",
    "events": [{
        "type": "Triggers",
        "id": "Item Event"
    }]
}
"""
    let item2Data = """
{
    "id": "Item 2",
    "name": "Item 2",
    "gameVersion": "1",
    "itemType": "Loot",
    "itemDisplayType": "Loot",
    "events": [{
        "type": "BlockedUntil",
        "id": "Item Event"
    }]
}
"""
    let itemEventData = """
{
    "id": "Item Event",
    "gameVersion": "1"
}
"""

    let decisionData = """
{
    "id": "Decision",
    "name": "Decision",
    "gameVersion": "1",
    "linkedEventIds": ["Decision Event"]
}
"""
    let decisionEventData = """
{
    "id": "Decision Event",
    "gameVersion": "1"
}
"""

    func testMigration() {
        initializeCurrentGame() // needed for saving event with game uuid

        let testOldDate = Date(timeIntervalSinceNow: -1000)

        // initialize mission data without event
        var mission1 = create(Mission.self, from: mission1Data)
        let mission2 = create(Mission.self, from: mission2Data)
        mission1?.isCompleted = true
        mission1?.completedDate = testOldDate
        _ = mission1?.save()

        // initialize item data without event
        var item1 = create(Item.self, from: item1Data)
        let item2 = create(Item.self, from: item2Data)
        item1?.isAcquired = true
        item1?.acquiredDate = testOldDate
        _ = item1?.save()

        // initialize decision data without event
        var decision = create(Decision.self, from: decisionData)
        decision = decision?.changed(isSelected: true)
        decision?.selectedDate = testOldDate
        _ = decision?.save()

        // initialize events
        let missionEvent = create(DataEvent.self, from: missionEventData)
        let itemEvent = create(DataEvent.self, from: itemEventData)
        let decisionEvent = create(DataEvent.self, from: decisionEventData)

        // reinitialize mission data (aka BaseDataMigration)
        _ = create(DataMission.self, from: mission1Data)
        _ = create(DataMission.self, from: mission2Data)
        _ = create(DataItem.self, from: item1Data)
        _ = create(DataItem.self, from: item2Data)
        _ = create(DataDecision.self, from: decisionData)

        // verify initial state
        XCTAssertFalse(Mission.get(id: mission2?.id ?? "")?.isAvailable ?? true)
        XCTAssertFalse(Item.get(id: item2?.id ?? "")?.isAvailable ?? true)
        XCTAssertFalse(Event.get(id: decisionEvent?.id ?? "")?.isTriggered ?? true)

        // run migration to retroactively trigger events
        EventTriggerMigration().run()

        // test that events were triggered
        XCTAssertTrue(Mission.get(id: mission2?.id ?? "")?.isAvailable ?? false)
        XCTAssertTrue(Item.get(id: item2?.id ?? "")?.isAvailable ?? false)
        XCTAssertTrue(Event.get(id: decisionEvent?.id ?? "")?.isTriggered ?? false)

        // test the event dates were changed to match
        XCTAssertTrue(roughlyEqualDates(Event.get(id: missionEvent?.id ?? "")?.triggeredDate, testOldDate))
        XCTAssertTrue(roughlyEqualDates(Event.get(id: itemEvent?.id ?? "")?.triggeredDate, testOldDate))
        XCTAssertTrue(roughlyEqualDates(Event.get(id: decisionEvent?.id ?? "")?.triggeredDate, testOldDate))
    }

    private func roughlyEqualDates(
        _ date1: Date?,
        _ date2: Date?,
        allowedDifference: TimeInterval = 1.0
    ) -> Bool {
        guard let date1 = date1, let date2 = date2 else { return false }
        return abs(date1.timeIntervalSince(date2)) < allowedDifference
    }
}
