//
//  Change20171022Tests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 9/4/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class Change20171022Tests: MEGameTrackerTests {

    let mission1From = """
    {
        "id": "A1.T.StrangeBehavior",
        "sortIndex": 220,
        "gameVersion": "1",
        "missionType": "Task",
        "name": "Feros: Strange Behavior",
        "conversationRewards": [{
            "set": {
                "isExclusiveSet": true,
                "context": "Speaking to the Calantha Blake",
                "options": [{
                    "id": "A1.T.StrangeBehavior.P1",
                    "type": "Paragon",
                    "value": 2,
                    "trigger": "\\"What's wrong?\\""
                }, {
                    "id": "A1.T.StrangeBehavior.R1",
                    "type": "Renegade",
                    "value": 2,
                    "trigger": "\\"I hope you're not contagious.\\""
                }]
            }
        }, {
            "set": {
                "isExclusiveSet": true,
                "context": "Speaking to Ian Newstead",
                "options": [{
                    "id": "A1.T.StrangeBehavior.P2",
                    "type": "Paragon",
                    "value": 2,
                    "trigger": "\\"Can I help?\\""
                }, {
                    "id": "A1.T.StrangeBehavior.R2",
                    "type": "Renegade",
                    "value": 2,
                    "trigger": "\\"Kill him.\\" (Does not kill him.)"
                }]
            }
        }]
    }
"""

    let mission2From = """
    {
        "id": "A1.T.StrangeBehavior.1",
        "sortIndex": 22001,
        "gameVersion": "1",
        "missionType": "Objective",
        "name": "Calantha and Hollis Blake",
        "inMissionId": "A1.T.StrangeBehavior",
    }
"""

    let mission12To = """
{
        "id": "A1.Convo.Feros.Blakes",
        "inMissionId": "A1.Convo.Feros",
        "sortIndex": 9010,
        "gameVersion": "1",
        "missionType": "Objective",
        "titlePrefix": "Conversation: ",
        "name": "Calantha and Hollis Blake",
        "conversationRewards": [{
            "set": {
                "isExclusiveSet": true,
                "context": "Speaking to Calantha Blake",
                "options": [{
                    "id": "A1.Convo.Feros.Blakes.P1",
                    "type": "Paragon",
                    "value": 2,
                    "trigger": "\\"What's wrong?\\""
                }, {
                    "id": "A1.Convo.Feros.Blakes.R1",
                    "type": "Renegade",
                    "value": 2,
                    "trigger": "\\"I hope you're not contagious.\\""
                }]
            }
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

        let fromMission1 = create(Mission.self, from: mission1From)
        let fromMission2 = create(Mission.self, from: mission2From)
        _ = fromMission1?.changed(conversationRewardId: "A1.T.StrangeBehavior.P1", isSelected: true)
        _ = fromMission2?.changed(isCompleted: true)

        App.current.lastBuild = 1 // required to run
        Change20171022().run()
        _ = create(DataMission.self, from: mission12To)

        let toMission12 = Mission.get(id: "A1.Convo.Feros.Blakes")
        XCTAssertTrue(
            toMission12?.isCompleted ?? false,
            "Completed status not transferred"
        )
        XCTAssertEqual(
            toMission12?.selectedConversationRewards ?? [],
            ["A1.Convo.Feros.Blakes.P1"],
            "Morality choice not transferred"
        )
    }
}
