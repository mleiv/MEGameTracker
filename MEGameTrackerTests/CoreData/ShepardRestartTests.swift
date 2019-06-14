//
//  ShepardRestartTests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 6/13/19.
//  Copyright © 2019 Emily Ivie. All rights reserved.
//

import XCTest
import Nuke
@testable import MEGameTracker

final class ShepardRestartTests: MEGameTrackerTests {

    // swiftlint:disable line_length

    let event1Json = "{\"id\": \"E1\",\"gameVersion\": \"1\",\"description\": \"\"}"
    let event2Json = "{\"id\": \"E2\",\"gameVersion\": \"2\",\"description\": \"\"}"
    let event3Json = "{\"id\": \"E3\",\"gameVersion\": \"3\",\"description\": \"\"}"

    let loveInterestDecision1Json = "{\"id\": \"D1.LoveLiara\",\"gameVersion\": \"1\",\"name\": \"Romanced Liara\",\"loveInterestId\": \"S1.Liara\"}"
    let loveInterestDecision2Json = "{\"id\": \"D2.LoveLiara\",\"gameVersion\": \"2\",\"name\": \"Romanced Liara\",\"loveInterestId\": \"S1.Liara\"}"
    let loveInterestDecision3Json = "{\"id\": \"D3.LoveLiara\",\"gameVersion\": \"3\",\"name\": \"Romanced Liara\",\"loveInterestId\": \"S1.Liara\"}"

    let mapAllJson = "{\"id\": \"G\",\"name\": \"Map All\",\"referenceSize\": \"2083x2083\",\"image\": null, \"mapType\": \"Planet\"}"
    let map1Json = "{\"id\": \"G.1\",\"name\": \"Map 1\",\"referenceSize\": \"2083x2083\",\"image\": null, \"mapType\": \"Planet\"}"
    let map2Json = "{\"id\": \"G.2\",\"name\": \"Map 2\",\"referenceSize\": \"2083x2083\",\"image\": null, \"mapType\": \"Planet\"}"
    let map3Json = "{\"id\": \"G.3\",\"name\": \"Map 3\",\"referenceSize\": \"2083x2083\",\"image\": null, \"mapType\": \"Planet\"}"

    let mission1Json = "{\"id\": \"M1.1\",\"gameVersion\": \"1\",\"missionType\": \"Mission\",\"name\": \"Mission 1\"}"
    let mission2Json = "{\"id\": \"M2.1\",\"gameVersion\": \"2\",\"missionType\": \"Mission\",\"name\": \"Mission 2\"}"
    let mission3Json = "{\"id\": \"M3.1\",\"gameVersion\": \"3\",\"missionType\": \"Mission\",\"name\": \"Mission 3\"}"

    let item1Json = "{\"id\": \"M1.I.1\",\"gameVersion\": \"1\",\"itemType\": \"MedKit\",\"itemDisplayType\": \"MedKit\",\"name\": \"MedKit 1\",\"inMapId\": \"G.1\",\"mapLocationPoint\": {\"x\": 0,\"y\": 0,\"radius\": 1}}"
    let item2Json = "{\"id\": \"M2.I.1\",\"gameVersion\": \"2\",\"itemType\": \"MedKit\",\"itemDisplayType\": \"MedKit\",\"name\": \"MedKit 2\",\"inMapId\": \"G.1\",\"mapLocationPoint\": {\"x\": 0,\"y\": 0,\"radius\": 1}}"
    let item3Json = "{\"id\": \"M3.I.1\",\"gameVersion\": \"3\",\"itemType\": \"MedKit\",\"itemDisplayType\": \"MedKit\",\"name\": \"MedKit 3\",\"inMapId\": \"G.1\",\"mapLocationPoint\": {\"x\": 0,\"y\": 0,\"radius\": 1}}"
    
    let liaraJson = "{\"id\": \"S1.Liara\",\"name\": \"Liara T\'soni\",\"personType\": \"Squad\",\"isMaleLoveInterest\": true,\"isFemaleLoveInterest\": true,\"race\": \"Asari\",\"profession\": \"Scientist\",\"organization\": null,\"loveInterestDecisionId\": \"D1.LoveLiara\", \"D2.LoveLiara\", \"D3.LoveLiara\"}"

    override func setUp() {
        super.setUp()

        initializeCurrentGame() // needed for game version
        initializeGameVersionEvents()

        let event1 = create(Event.self, from: event1Json)
        let event2 = create(Event.self, from: event2Json)
        let event3 = create(Event.self, from: event3Json)

        _ = create(Decision.self, from: loveInterestDecision1Json)
        _ = create(Decision.self, from: loveInterestDecision2Json)
        _ = create(Decision.self, from: loveInterestDecision3Json)

        var mapAll = create(Map.self, from: mapAllJson)
        let map1 = create(Map.self, from: map1Json)
        var map2 = create(Map.self, from: map2Json)
        var map3 = create(Map.self, from: map3Json)

        let mission1 = create(Mission.self, from: mission1Json)
        let mission2 = create(Mission.self, from: mission2Json)
        let mission3 = create(Mission.self, from: mission3Json)

        let item1 = create(Item.self, from: item1Json)
        let item2 = create(Item.self, from: item2Json)
        let item3 = create(Item.self, from: item3Json)

        var shepard1 = App.current.game?.shepard
        shepard1 = shepard1?.changed(name: "Mustang")
        shepard1 = shepard1?.changed(class: .adept)
        shepard1 = shepard1?.changed(origin: .colonist)
        shepard1 = shepard1?.changed(reputation: .ruthless)
        shepard1 = shepard1?.changed(level: 10)

        shepard1 = shepard1?.changed(loveInterestId: "D1.LoveLiara")
        _ = event1?.changed(isTriggered: true)
        _ = map1?.changed(isExplored: true)
        mapAll = mapAll?.changed(isExplored: true)
        _ = mission1?.changed(isCompleted: true)
        _ = item1?.changed(isAcquired: true)

        App.current.game?.change(gameVersion: .game2)
        var shepard2 = App.current.game?.shepard
        shepard2 = shepard2?.changed(class: .engineer)
        shepard2 = shepard2?.changed(level: 20)

        shepard2 = shepard2?.changed(loveInterestId: "D2.LoveLiara")
        _ = event2?.changed(isTriggered: true)
        map2 = map2?.changed(gameVersion: .game2)
        _ = map2?.changed(isExplored: true)
        mapAll = mapAll?.changed(gameVersion: .game2)
        mapAll = mapAll?.changed(isExplored: true)
        _ = mission2?.changed(isCompleted: true)
        _ = item2?.changed(isAcquired: true)

        App.current.game?.change(gameVersion: .game3)
        var shepard3 = App.current.game?.shepard
        shepard3 = shepard3?.changed(level: 30)
        shepard3 = shepard3?.changed(loveInterestId: "D3.LoveLiara")
        _ = event3?.changed(isTriggered: true)
        map3 = map3?.changed(gameVersion: .game3)
        _ = map3?.changed(isExplored: true)
        mapAll = mapAll?.changed(gameVersion: .game3)
        _ = mapAll?.changed(isExplored: true)
        _ = mission3?.changed(isCompleted: true)
        _ = item3?.changed(isAcquired: true)
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRestart() {
        var oldGame = App.current.game
        var newGame = App.current.game?.restarted(at: .game2, isAllowDelay: false);

        XCTAssert(newGame?.shepard?.gameVersion == .game2, "Created at incorrect game")
        XCTAssert(oldGame?.uuid != newGame?.uuid, "Restarted game has same uuid")

        oldGame?.change(gameVersion: .game1)
        newGame?.change(gameVersion: .game1)
        compareShepardShared(old: oldGame!.shepard!, new: newGame!.shepard!)
        compareShepardChoicesFound(old: oldGame!, new: newGame!)

        oldGame?.change(gameVersion: .game2)
        newGame?.change(gameVersion: .game2)
        compareShepardShared(old: oldGame!.shepard!, new: newGame!.shepard!)
        compareShepardChoicesReset(old: oldGame!, new: newGame!)

        let oldShepards = Shepard.getAll(gameSequenceUuid: oldGame!.uuid)
        let newShepards = Shepard.getAll(gameSequenceUuid: newGame!.uuid)
        XCTAssert(oldShepards.count == 3, "Old shepard missing shepard v3")
        XCTAssert(newShepards.count == 2, "Restarted shepard copied shepard v3")
        XCTAssert(Array(Set(oldShepards.map({$0.uuid}) + newShepards.map({$0.uuid}))).count == 5, "Duplicate uuids found")

        oldGame?.change(gameVersion: .game3)
        newGame?.change(gameVersion: .game3)
        compareShepardChoicesReset(old: oldGame!, new: newGame!)
    }

    private func compareShepardShared(old oldShepard: Shepard, new newShepard: Shepard) {
        XCTAssert(oldShepard.uuid != newShepard.uuid, "Restarted shepard has same uuid")
        XCTAssert(oldShepard.name == newShepard.name, "Restarted shepard has wrong name")
        XCTAssert(oldShepard.classTalent == newShepard.classTalent, "Restarted shepard has wrong class")
        XCTAssert(oldShepard.origin == newShepard.origin, "Restarted shepard has wrong origin")
        XCTAssert(oldShepard.reputation == newShepard.reputation, "Restarted shepard has wrong reputation")
    }

    private func compareShepardChoicesFound(old oldGame: GameSequence, new newGame: GameSequence) {
        XCTAssert(oldGame.shepard!.level == newGame.shepard!.level, "Restarted shepard has wrong level")

        // decision
        XCTAssert(oldGame.shepard!.loveInterestId == newGame.shepard!.loveInterestId, "Restarted shepard has wrong love interest")

        let eventId: String
        let mapId: String
        let missionId: String
        let itemId: String
        switch (oldGame.gameVersion) {
        case .game1:
            eventId = "E1"
            mapId = "G.1"
            missionId = "M1.1"
            itemId = "M1.I.1"
        case .game2:
            eventId = "E2"
            mapId = "G.2"
            missionId = "M2.1"
            itemId = "M2.I.1"
        case .game3:
            eventId = "E3"
            mapId = "G.3"
            missionId = "M3.1"
            itemId = "M3.I.1"
        }

        let oldEvent = Event.getAllExisting(ids: [eventId], gameSequenceUuid: oldGame.uuid).randomElement()
        let newEvent = Event.getAllExisting(ids: [eventId], gameSequenceUuid: newGame.uuid).randomElement()
        XCTAssert(oldEvent?.isTriggered == true && newEvent?.isTriggered == true, "Restarted shepard did not copy event")

        let oldMap = Map.getAllExisting(ids: [mapId], gameSequenceUuid: oldGame.uuid).randomElement()
        let newMap = Map.getAllExisting(ids: [mapId], gameSequenceUuid: newGame.uuid).randomElement()
        XCTAssert(oldMap?.isExploredPerGameVersion[oldGame.gameVersion] == true && newMap?.isExploredPerGameVersion[oldGame.gameVersion] == true, "Restarted shepard did not copy map")

        let oldMapAll = Map.getAllExisting(ids: ["G"], gameSequenceUuid: oldGame.uuid).randomElement()
        let newMapAll = Map.getAllExisting(ids: ["G"], gameSequenceUuid: newGame.uuid).randomElement()
        XCTAssert(oldMapAll?.isExploredPerGameVersion[oldGame.gameVersion] == true && newMapAll?.isExploredPerGameVersion[oldGame.gameVersion] == true, "Restarted shepard did not copy all map")

        let oldMission = Mission.getAllExisting(ids: [missionId], gameSequenceUuid: oldGame.uuid).randomElement()
        let newMission = Mission.getAllExisting(ids: [missionId], gameSequenceUuid: newGame.uuid).randomElement()
        XCTAssert(oldMission?.isCompleted == true && newMission?.isCompleted == true, "Restarted shepard did not copy mission")

        let oldItem = Item.getAllExisting(ids: [itemId], gameSequenceUuid: oldGame.uuid).randomElement()
        let newItem = Item.getAllExisting(ids: [itemId], gameSequenceUuid: newGame.uuid).randomElement()
        XCTAssert(oldItem?.isAcquired == true && newItem?.isAcquired == true, "Restarted shepard did not copy item")
    }

    private func compareShepardChoicesReset(old oldGame: GameSequence, new newGame: GameSequence) {
        let loveInterestId: String
        let eventId: String
        let mapId: String
        let missionId: String
        let itemId: String
        switch (oldGame.gameVersion) {
        case .game1:
            loveInterestId = "D1.LoveLiara"
            eventId = "E1"
            mapId = "G.1"
            missionId = "M1.1"
            itemId = "M1.I.1"
        case .game2:
            loveInterestId = "D2.LoveLiara"
            eventId = "E2"
            mapId = "G.2"
            missionId = "M2.1"
            itemId = "M2.I.1"
        case .game3:
            loveInterestId = "D3.LoveLiara"
            eventId = "E3"
            mapId = "G.3"
            missionId = "M3.1"
            itemId = "M3.I.1"
        }

        XCTAssert(oldGame.shepard!.level != newGame.shepard!.level, "Restarted shepard has wrong level")

        // decision
        XCTAssert(oldGame.shepard!.loveInterestId == loveInterestId && newGame.shepard!.loveInterestId == nil, "Restarted shepard has wrong love interest")

        let oldEvents = Event.getAllExisting(ids: [eventId], gameSequenceUuid: oldGame.uuid)
        let newEvents = Event.getAllExisting(ids: [eventId], gameSequenceUuid: newGame.uuid)
        XCTAssert(oldEvents.count == 1 && newEvents.count == 0, "Restarted shepard copied event from wrong game")

        let oldMap = Map.getAllExisting(ids: [mapId], gameSequenceUuid: oldGame.uuid).randomElement()
        let newMap = Map.getAllExisting(ids: [mapId], gameSequenceUuid: newGame.uuid).randomElement()
        XCTAssert(oldMap?.isExploredPerGameVersion[oldGame.gameVersion] == true && newMap?.isExploredPerGameVersion[oldGame.gameVersion] == false, "Restarted shepard copied map from wrong game")

        let oldMapAll = Map.getAllExisting(ids: ["G"], gameSequenceUuid: oldGame.uuid).randomElement()
        let newMapAll = Map.getAllExisting(ids: ["G"], gameSequenceUuid: newGame.uuid).randomElement()
        XCTAssert(oldMapAll?.isExploredPerGameVersion[oldGame.gameVersion] == true && newMapAll?.isExploredPerGameVersion[oldGame.gameVersion] == false, "Restarted shepard copied all map from wrong game")

        let oldMissions = Mission.getAllExisting(ids: [missionId], gameSequenceUuid: oldGame.uuid)
        let newMissions = Mission.getAllExisting(ids: [missionId], gameSequenceUuid: newGame.uuid)
        XCTAssert(oldMissions.count == 1 && newMissions.count == 0, "Restarted shepard copied mission from wrong game")

        let oldItems = Item.getAllExisting(ids: [itemId], gameSequenceUuid: oldGame.uuid)
        let newItems = Item.getAllExisting(ids: [itemId], gameSequenceUuid: newGame.uuid)
        XCTAssert(oldItems.count == 1 && newItems.count == 0, "Restarted shepard copied item from wrong game")
    }
}
