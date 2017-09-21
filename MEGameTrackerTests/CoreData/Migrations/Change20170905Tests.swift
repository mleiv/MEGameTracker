//
//  Change20170905Tests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 9/4/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class Change20170905Tests: MEGameTrackerTests {

    let itemFrom = """
{
    "id": "A1.C1.ScanTheKeepers.I.1",
    "gameVersion": "1",
    "itemType": "Collection",
    "itemDisplayType": "Goal",
    "name": "Keeper 1",
    "inMapId": "G.C1.Presidium",
    "inMissionId": "A1.C1.ScanTheKeepers",
    "mapLocationPoint": {
        "x": 2005,
        "y": 585,
        "radius": 1
    }
}
"""
    let itemTo = """
{
    "id": "A1.C1.ScanTheKeepers.I.01",
    "gameVersion": "1",
    "itemType": "Collection",
    "itemDisplayType": "Goal",
    "name": "Keeper 1",
    "inMapId": "G.C1.Presidium",
    "inMissionId": "A1.C1.ScanTheKeepers",
    "mapLocationPoint": {
        "x": 2005,
        "y": 585,
        "radius": 1
    }
}
"""

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Test migrating a decision
    func testRenameItems() {
        initializeCurrentGame() // needed for saving with game uuid

        let fromItem = create(Item.self, from: itemFrom)
        _ = create(Item.self, from: itemTo)
        _ = fromItem?.changed(isAcquired: true)

        App.current.lastBuild = 1 // required to run
        Change20170905().run()

        let deletedFromItem = Item.get(id: "A1.C1.ScanTheKeepers.I.1")
        let updatedToItem = Item.get(id: "A1.C1.ScanTheKeepers.I.01")
        XCTAssert(
            deletedFromItem == nil,
            "Old Item not deleted in migration"
        )
        XCTAssert(
            updatedToItem?.isAcquired == true,
            "Item status not migrated"
        )
    }
}
