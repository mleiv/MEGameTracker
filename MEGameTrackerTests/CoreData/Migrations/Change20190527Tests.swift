//
//  Change20190527Tests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 5/27/19.
//  Copyright © 2019 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class Change20190527Tests: MEGameTrackerTests {

    let mission1From = """
    {
        "id": "DLC3.Citadel2.10.9.1",
        "gameVersion": "3",
        "missionType": "Objective",
        "name": "Super-Elite Enemies"
    }
"""

    let mission1To = """
    {
        "id": "DLC3.Citadel3.10.1",
        "gameVersion": "3",
        "missionType": "Objective",
        "name": "Super-Elite Enemies"
    }
"""

    let missionConversationRewards1AFrom = """
    {
        "id": "A3.GethFighterSquadrons",
        "gameVersion": "3",
        "missionType": "Assignment",
        "name": "Rannoch: Geth Fighter Squadrons",
        "conversationRewards": [{
            "id": "A3.GethFighterSquadrons.P5A",
            "type": "Paragon",
            "value": 2,
            "trigger": ""
        }]
    }
"""
    let missionConversationRewards1BFrom = """
    {
        "id": "A3.AdmiralKoris",
        "gameVersion": "3",
        "missionType": "Assignment",
        "name": "Rannoch: Admiral Koris",
        "conversationRewards": [{
            "id": "A3.GethFighterSquadrons.P5A",
            "type": "Paragon",
            "value": 2,
            "trigger": ""
        }]
    }
"""
    let missionConversationRewards1ATo = """
    {
        "id": "A3.GethFighterSquadrons",
        "gameVersion": "3",
        "missionType": "Assignment",
        "name": "Rannoch: Geth Fighter Squadrons",
        "conversationRewards": [{
            "id": "A3.GethFighterSquadrons.P5A.Dup1",
            "type": "Paragon",
            "value": 2,
            "trigger": ""
        }]
    }
"""
    let missionConversationRewards1BTo = """
    {
        "id": "A3.AdmiralKoris",
        "gameVersion": "3",
        "missionType": "Assignment",
        "name": "Rannoch: Admiral Koris",
        "conversationRewards": [{
            "id": "A3.GethFighterSquadrons.P5A.Dup2",
            "type": "Paragon",
            "value": 2,
            "trigger": ""
        }]
    }
"""

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Test migrating a decision to a brand-new mission (does not exist at time of migration)
    func testMoveMissions() {
        initializeCurrentGame() // needed for saving with game uuid

        let mission1 = create(Mission.self, from: mission1From)
        let missionConversationRewards1A = create(Mission.self, from: missionConversationRewards1AFrom)
        let missionConversationRewards1B = create(Mission.self, from: missionConversationRewards1BFrom)
        _ = mission1?.changed(isCompleted: true)
        _ = missionConversationRewards1A?.changed(conversationRewardId: "A3.GethFighterSquadrons.P5A", isSelected: true)
        _ = missionConversationRewards1B?.changed(conversationRewardId: "A3.GethFighterSquadrons.P5A", isSelected: true)

        App.current.lastBuild = 1 // required to run
        Change20190527().run()

        _ = create(DataMission.self, from: mission1To)
        _ = create(DataMission.self, from: missionConversationRewards1ATo)
        _ = create(DataMission.self, from: missionConversationRewards1BTo)

        let test1 = Mission.get(id: "DLC3.Citadel3.10.1")
        XCTAssertTrue(
            test1?.isCompleted ?? false,
            "Completed status not transferred"
        )
        let test2A = Mission.get(id: "A3.GethFighterSquadrons")
        let test2B = Mission.get(id: "A3.AdmiralKoris")
        XCTAssertEqual(
            test2A?.selectedConversationRewards ?? [],
            ["A3.GethFighterSquadrons.P5A.Dup1"],
            "Morality choice not transferred"
        )
        XCTAssertEqual(
            test2B?.selectedConversationRewards ?? [],
            ["A3.GethFighterSquadrons.P5A.Dup2"],
            "Morality choice not transferred"
        )
    }
}
