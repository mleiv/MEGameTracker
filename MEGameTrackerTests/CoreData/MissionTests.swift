//
//  MissionTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/23/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class MissionTests: MEGameTrackerTests {

	// swiftlint:disable line_length

	let garrusJson = "{\"id\": \"M1.Garrus\",\"sortIndex\": 3,\"gameVersion\": \"1\",\"missionType\": \"Mission\",\"name\": \"Citadel: Garrus\",\"isOptional\": true,\"inMapId\": \"G.C1.Tower\",\"mapLocationPoint\": {\"x\": 1049,\"y\": 571,\"radius\": true},\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Citadel:_Expose_Saren#Report_to_the_Council\"],\"relatedMissionIds\": [\"M1.ExposeSaren\", \"M1.ShadowBroker\"]}"

	let garrus1Json = "{\"id\": \"M1.Garrus.1\",\"gameVersion\": \"1\",\"missionType\": \"Objective\",\"name\": \"Speak to Harkin\",\"inMissionId\": \"M1.Garrus\"}"

	let garrus2Json = "{\"id\": \"M1.Garrus.2\",\"gameVersion\": \"1\",\"missionType\": \"Objective\",\"name\": \"Go to the Med Clinic\",\"inMissionId\": \"M1.Garrus\"}"

	let insigniasJson = "{\"id\": \"A1.UC.TurianInsignias\",\"sortIndex\": 45,\"gameVersion\": \"1\",\"missionType\": \"Collection\",\"name\": \"UNC: Turian Insignias\",\"aliases\": [\"UNC: Turian Insignias\", \"UNC: Collection Complete\"],\"objectivesCountToCompletion\": 2,\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/UNC:_Turian_Insignias\"]}"

	let insignias1Json = "{\"id\": \"A1.UC.TurianInsignias.I.1\",\"gameVersion\": \"1\",\"itemType\": \"Collection\",\"itemDisplayType\": \"Goal\",\"name\": \"Turian Insignia: Gothis Colony\",\"inMissionId\": \"A1.UC.TurianInsignias\"}"

	let insignias2Json = "{\"id\": \"A1.UC.TurianInsignias.I.2\",\"gameVersion\": \"1\",\"itemType\": \"Collection\",\"itemDisplayType\": \"Goal\",\"name\": \"Turian Insignia: Parthia Colony\",\"inMissionId\": \"A1.UC.TurianInsignias\"}"

	let insignias3Json = "{\"id\": \"A1.UC.TurianInsignias.I.3\",\"gameVersion\": \"1\",\"itemType\": \"Collection\",\"itemDisplayType\": \"Goal\",\"name\": \"Turian Insignia: Edessan Colony\",\"inMissionId\": \"A1.UC.TurianInsignias\"}"

	let digJson = "{\"id\": \"A2.N7.ArcheologicalDig\",\"sortIndex\": 10,\"gameVersion\": \"2\",\"missionType\": \"Assignment\",\"name\": \"N7: Archeological Dig Site\",\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/N7:_Archeological_Dig_Site\"],\"events\": [{\"type\": \"Triggers\",\"id\": \"Completed: Joab Prothean Pyramid\"}]}"

	let pyramidJson = "{\"id\": \"Completed: Joab Prothean Pyramid\",\"gameVersion\": \"2\"}"

	// swiftlint:enable line_length

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testEquality() {
		let mission1 = create(Mission.self, from: garrusJson)
		let mission2 = create(Mission.self, from: garrusJson)
		XCTAssert(mission1 == mission2, "Equality not working")
	}

	/// Test Mission get methods.
	func testGetOne() {
		_ = create(Mission.self, from: garrusJson)
		let mission = Mission.get(id: "M1.Garrus")
		XCTAssert(mission?.name == "Citadel: Garrus", "Failed to load by id")
	}

	/// Test Mission getAll methods.
	func testGetAll() {
		_ = create(Mission.self, from: garrusJson)
		_ = create(Mission.self, from: insigniasJson)
		_ = create(Mission.self, from: digJson)
		let missions = Mission.getAll()
		XCTAssert(missions.count == 3, "Failed to get all missions")
	}

	/// Test Mission sort method.
	func testSort() {
		initializeCurrentGame() // needed for game version
		initializeGameVersionEvents()
		_ = create(Mission.self, from: garrusJson)
		_ = create(Mission.self, from: insigniasJson)
		_ = create(Mission.self, from: digJson)
		// sorts by sort index, availability
		let matches1 = Mission.getAll().sorted(by: Mission.sort)
        if matches1.count == 3 {
            XCTAssert(matches1[0].id == "M1.Garrus",
                "Failed to sort mission 1 correctly")
            XCTAssert(matches1[1].id == "A1.UC.TurianInsignias",
                "Failed to sort mission 2 correctly")
            XCTAssert(matches1[2].id == "A2.N7.ArcheologicalDig",
                "Failed to sort mission 3 correctly")
        }
	}

	/// Test Mission game version variations.
	func testGetByGameVersion() {
		initializeCurrentGame() // needed for game version, saving with game uuid
		initializeGameVersionEvents()
		let mission = create(Mission.self, from: garrusJson)
		_ = create(Mission.self, from: insigniasJson)
		_ = create(Mission.self, from: digJson)
		// mission is blocked in Game 2
		App.current.game?.change(gameVersion: .game2)
		XCTAssert(mission?.isAvailable == false,
			"Failed to make mission unavailable in game version")
		let matches1 = Mission.getAll(gameVersion: .game1)
		XCTAssert(matches1.count == 2, "Failed to get all game 1 missions")
		let matches2 = Mission.getAll(gameVersion: .game2)
		XCTAssert(matches2.count == 1, "Failed to get all game 2 missions")
	}

	/// Test Mission change action.
	func testChange() {
		initializeCurrentGame() // needed for saving with game uuid

		var mission = create(Mission.self, from: garrusJson)
		XCTAssert(mission?.isCompleted == false,
			"Reported incorrect initial mission state")

		// - verify signal is fired
		let expectationMissionCompleted = expectation(description: "Mission on change triggered")
		Mission.onChange.subscribe(on: self) { (changed: (id: String, object: Mission?)) in
			if changed.id == "M1.Garrus",
				let mission = changed.object ?? Mission.get(id: changed.id),
				mission.isCompleted {
				expectationMissionCompleted.fulfill()
			}
		}

		_ = mission?.changed(isCompleted: true)
		mission = Mission.get(id: "M1.Garrus")
		XCTAssert(mission?.isCompleted == true,
			"Reported incorrect completed mission state")

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		Mission.onChange.cancelSubscription(for: self)
	}

	/// Test getting all mission objectives.
	func testGetObjectives() {
		// verify objectives returned
		let mission1 = create(Mission.self, from: garrusJson)
		_ = create(Mission.self, from: garrus1Json)
		_ = create(Mission.self, from: garrus2Json)
		let objectives1 = mission1?.getObjectives() ?? []
		XCTAssert(objectives1.count == 2, "Failed to get all mission objectives")

		let mission2 = create(Mission.self, from: insigniasJson)
		_ = create(Item.self, from: insignias1Json)
		_ = create(Item.self, from: insignias2Json)
		_ = create(Item.self, from: insignias3Json)
		let objectives2 = mission2?.getObjectives() ?? []
		XCTAssert(objectives2.count == 3, "Failed to get all mission item objectives")
	}

	/// Test completing a mission with objectives.
	func testCompleteObjectives() {
		initializeCurrentGame() // needed for saving with game uuid

		var mission = create(Mission.self, from: garrusJson)
		var objective1 = create(Mission.self, from: garrus1Json)
		let objective2 = create(Mission.self, from: garrus2Json)

		// #1 verify mission marked completed when all objectives completed

		// - verify signal is fired
		let expectationMissionCompleted = expectation(description: "Mission on change triggered")
		Mission.onChange.subscribe(on: self) { (changed: (id: String, object: Mission?)) in
			if changed.id == "M1.Garrus",
				let mission = changed.object ?? Mission.get(id: changed.id),
				mission.isCompleted {
				// not 100% accurate, since any of the other tests could trigger this listener.
				// urg inadequate test sandboxing.
				expectationMissionCompleted.fulfill()
			}
		}

		objective1 = objective1?.changed(isCompleted: true)
		_ = objective2?.changed(isCompleted: true)
		mission = Mission.get(id: "M1.Garrus")
		XCTAssert(mission?.isCompleted == true,
			"Failed to complete mission when all mission objectives completed")

		waitForExpectations(timeout: 0.1) { _ in }
		Mission.onChange.cancelSubscription(for: self)

		// #2 verify mission marked uncompleted when all objectives not completed

		// - verify signal is fired
		let expectationMissionUncompleted = expectation(description: "Mission on change triggered")
		Mission.onChange.subscribe(on: self) { (changed: (id: String, object: Mission?)) in
			if changed.id == "M1.Garrus",
				let mission = changed.object ?? Mission.get(id: changed.id),
				!mission.isCompleted {
				// not 100% accurate, since any of the other tests could trigger this listener.
				// urg inadequate test sandboxing.
				expectationMissionUncompleted.fulfill()
			}
		}

		_ = objective1?.changed(isCompleted: false)
		mission = Mission.get(id: "M1.Garrus")
		XCTAssert(mission?.isCompleted == false,
			"Failed to uncomplete mission when a mission objective uncompleted")

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		Mission.onChange.cancelSubscription(for: self)
	}

	/// Test completing a mission with objectives.
	func testCompleteMission() {
		initializeCurrentGame() // needed for saving with game uuid

		let mission = create(Mission.self, from: garrusJson)
		var objective1 = create(Mission.self, from: garrus1Json)
		_ = create(Mission.self, from: garrus2Json)

		// #3 verify objectives marked completed when mission completed

		// - verify signal is fired
		let expectationMissionCompleted2 = expectation(description: "Mission on change triggered")
		Mission.onChange.subscribe(on: self) { (changed: (id: String, object: Mission?)) in
			if changed.id == "M1.Garrus",
				let mission = changed.object ?? Mission.get(id: changed.id),
				mission.isCompleted {
				// not 100% accurate, since any of the other tests could trigger this listener.
				// urg inadequate test sandboxing.
				expectationMissionCompleted2.fulfill()
			}
		}

		_ = mission?.changed(isCompleted: true)
		objective1 = Mission.get(id: "M1.Garrus.1")
		XCTAssert(objective1?.isCompleted == true,
			"Failed to complete objective when mission completed")

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		Mission.onChange.cancelSubscription(for: self)

		// #4 verify objectives NOT marked uncompleted when mission uncompleted

		_ = mission?.changed(isCompleted: false)
		objective1 = Mission.get(id: "M1.Garrus.1")
		XCTAssert(objective1?.isCompleted == true,
			"Incorrectly uncompleted objective when mission uncompleted")
	}

	/// Test completing a mission with a max limit on objectives.
	/// These are item objectives, but that should not matter.
	func testCompleteLimitedObjectives() {
		initializeCurrentGame() // needed for saving with game uuid

		var mission = create(Mission.self, from: insigniasJson)
		var objective1 = create(Item.self, from: insignias1Json)
		var objective2 = create(Item.self, from: insignias2Json)
		var objective3 = create(Item.self, from: insignias3Json)

		// #1 verify mission marked completed with max limit of objectives

		// - verify signal is fired
		let expectationMissionCompleted = expectation(description: "Mission on change triggered")
		Mission.onChange.subscribe(on: self) { (changed: (id: String, object: Mission?)) in
			if changed.id == "A1.UC.TurianInsignias",
				let mission = changed.object ?? Mission.get(id: changed.id),
				mission.isCompleted {
				// not 100% accurate, since any of the other tests could trigger this listener.
				// urg inadequate test sandboxing.
				expectationMissionCompleted.fulfill()
			}
		}

		// (only requires two of three)
		_ = objective1?.changed(isAcquired: true)
		objective2 = objective2?.changed(isAcquired: true)
		mission = Mission.get(id: "A1.UC.TurianInsignias")
		XCTAssert(mission?.isCompleted == true,
			"Failed to complete mission when max necessary mission objectives completed")

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		Mission.onChange.cancelSubscription(for: self)

		// #2 verify mission marked uncompleted with max limit of objectives

		// - verify signal is fired
		let expectationMissionUncompleted = expectation(description: "Mission on change triggered")
		Mission.onChange.subscribe(on: self) { (changed: (id: String, object: Mission?)) in
			if changed.id == "A1.UC.TurianInsignias",
				let mission = changed.object ?? Mission.get(id: changed.id),
				!mission.isCompleted {
				// not 100% accurate, since any of the other tests could trigger this listener.
				// urg inadequate test sandboxing.
				expectationMissionUncompleted.fulfill()
			}
		}

		_ = objective2?.changed(isAcquired: false)
		mission = Mission.get(id: "A1.UC.TurianInsignias")
		XCTAssert(mission?.isCompleted == false,
			"Failed to uncomplete mission when a max necessary mission objective uncompleted")

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		Mission.onChange.cancelSubscription(for: self)

		// #3 verify objectives with max limit NOT marked completed when mission completed

		_ = mission?.changed(isCompleted: true)
		objective3 = Item.get(id: "A1.UC.TurianInsignias.I.3")
		XCTAssert(objective3?.isAcquired == false,
			"Incorrectly completed objective when mission completed")

		// #4 verify objectives with max limit NOT marked uncompleted when mission uncompleted

		_ = mission?.changed(isCompleted: false)
		objective1 = Item.get(id: "A1.UC.TurianInsignias.I.1")
		XCTAssert(objective1?.isAcquired == true,
			"Incorrectly uncompleted objective when mission uncompleted")
	}

	/// Test Mission event triggers.
	func testTriggerEvent() {
		initializeCurrentGame() // needed for saving with game uuid

		// complete a mission with a trigger event

		_ = create(Event.self, from: pyramidJson)
		let mission = create(Mission.self, from: digJson)
		_ = mission?.changed(isCompleted: true)
		let event = Event.get(id: "Completed: Joab Prothean Pyramid")
		XCTAssert(event?.isTriggered == true, "Reported incorrect triggered event state")
	}

    func testCompletedAfter() {
        initializeCurrentGame() // needed for saving with game uuid

        guard let beforeDate = Calendar.current.date(byAdding: .second, value: -1, to: Date())
            else { XCTAssert(false); return; }

        let mission = create(Mission.self, from: digJson)
        _ = mission?.changed(isCompleted: true)
        let missionsAfterDate = Mission.getCompletedCount(
            after: beforeDate,
            missionTypes: MissionType.anyMissionTriggers,
            gameVersion: mission?.gameVersion ?? .game1
        )
        XCTAssertEqual(missionsAfterDate, 1)
    }
}
