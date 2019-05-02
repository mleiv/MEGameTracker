//
//  EventTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/23/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class EventTests: MEGameTrackerTests {

	// swiftlint:disable line_length

	let noveria1Json = "{\"id\": \"Noveria Landlines Repaired\",\"gameVersion\": \"1\",\"description\": \"[megametracker:\\/\\/mission?id=M1.Noveria.5Landlines]\"}"

	let noveria2Json = "{\"id\": \"Noveria Reactor Repaired\",\"gameVersion\": \"1\",\"description\": \"[megametracker:\\/\\/mission?id=M1.Noveria.6Reactor]\"}"

	let noveriaCombinedJson = "{\"id\": \"Noveria Peak 15 Repaired\",\"gameVersion\": \"1\",\"description\": \"[megametracker:\\/\\/mission?id=M1.Noveria.5Landlines] and [megametracker:\\/\\/mission?id=M1.Noveria.6Reactor]\",\"dependentOn\": {\"countTo\": 2,\"events\": [\"Noveria Landlines Repaired\",\"Noveria Reactor Repaired\"]}}"

	let noveriaCombinedMissionJson = "{\"id\": \"M1.Noveria.7Contamination\",\"gameVersion\": \"1\",\"sortIndex\": 12,\"missionType\": \"Mission\",\"name\": \"Noveria: Contamination\",\"events\": [{\"type\": \"BlockedUntil\",\"id\": \"Noveria Peak 15 Repaired\"}]}"

	let prologueMissionJson = "{\"id\": \"M1.Prologue\",\"sortIndex\": 1,\"gameVersion\": \"1\",\"missionType\": \"Mission\",\"name\": \"Prologue: On The Normandy\",\"aliases\": [\"Prologue: On The Normandy\", \"Prologue: Find The Beacon\"]}"

	let prologueEventJson = "{\"id\": \"Unlocked Eden Prime\",\"gameVersion\": \"1\",\"description\": \"[megametracker:\\/\\/mission?id=M1.Prologue.1]\",\"actions\": [{\"target\": {\"type\": \"Mission\",\"id\": \"M1.Prologue\"},\"changes\": {\"On\": {\"name\": \"Prologue: Find The Beacon\"},\"Off\": {\"name\": \"Prologue: On The Normandy\"}}}]}"

	let wrexDecisionJson = "{\"id\": \"D1.WrexArmor\",\"gameVersion\": \"1\",\"name\": \"Retrieved Wrex\'s family armor\",\"description\": \"Wrex will trust Shepard if Shepard helps him retrieve his family\'s armor. The argument later on Virmire will end peacefully if this occurs.\",\"sortIndex\": 81}"

	let wrexEventJson = "{\"id\": \"Acquired Wrex\'s Family Armor\",\"gameVersion\": \"1\",\"description\": \"[megametracker:\\/\\/mission?id=A1.L.WrexFamilyArmor]\",\"actions\": [{\"target\": {\"type\": \"Decision\",\"id\": \"D1.WrexArmor\"},\"changes\": {\"On\": {\"isSelected\": true},\"Off\": {\"isSelected\": false}}}]}"

	let prologue2EventJson = "{\"id\": \"Completed: Prologue 1\", \"gameVersion\": \"2\",\"description\": \"[megametracker:\\/\\/mission?id=M2.Prologue1]\"}"

    let additiveEventBase = """
	{
        "id": "Completed: Additive Event Base",
        "gameVersion": "1"
	}
""";
    let additiveMission = """
    {
        "id": "Additive Mission",
        "name": "Additive Mission",
        "gameVersion": "1",
        "missionType": "Assignment"
    }
""";
    let additiveEventTarget = """
    {
      "id": "Completed: Additive Event Base + 1",
      "gameVersion": "1",
      "isAny": "missions",
      "dependentOn": {
         "countTo": 1,
         "events": [
            "Any Mission After: Completed: Additive Event Base"
         ]
      }
    }
""";

	// swiftlint:enable line_length

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testEquality() {
		let event1 = create(Event.self, from: noveria1Json)
		let event2 = create(Event.self, from: noveria1Json)
		XCTAssert(event1 == event2, "Equality not working")
	}

	/// Test Event get methods.
	func testGetOne() {
		_ = create(Event.self, from: noveria1Json)
		let noveria1 = Event.get(id: "Noveria Landlines Repaired")
		XCTAssert(noveria1?.id == "Noveria Landlines Repaired", "Failed to load by id")
	}

	/// Test Event getAll methods.
	func testGetAll() {
		_ = create(Event.self, from: noveria1Json)
		_ = create(Event.self, from: noveria2Json)
		_ = create(Event.self, from: noveriaCombinedJson)
		let events = Event.getAll()
		XCTAssert(events.count == 3, "Failed to get all events")
	}

	/// Test Event game version variations
	func testGetByGameVersion() {
		initializeCurrentGame() // needed for game version
		_ = create(Event.self, from: noveria1Json)
		_ = create(Event.self, from: noveria2Json)
		_ = create(Event.self, from: prologue2EventJson)
		let matches1 = Event.getAll(gameVersion: .game1)
		XCTAssert(matches1.count == 2, "Failed to get all game 1 events")
		let matches2 = Event.getAll(gameVersion: .game2)
		XCTAssert(matches2.count == 1, "Failed to get all game 2 events")
	}

	/// Test Event change action.
	func testChange() {
		initializeCurrentGame() // needed for saving event with game uuid

		let event = create(Event.self, from: noveria1Json)
		XCTAssert(event?.isTriggered == false, "Reported incorrect initial event state")
		_ = event?.changed(isTriggered: true, isSave: true)
		let event2 = Event.get(id: "Noveria Landlines Repaired")
		XCTAssert(event2?.isTriggered == true, "Reported incorrect triggered event state")

		// events don't fire on change for just the event
	}

	/// Test Event change action which alters other objects.
	func testChangeValues() {
		initializeCurrentGame() // needed for saving event with game uuid

		// #1 Event changes mission title

		// - verify signal is fired
        let expectationMissionOnChange = expectation(description: "Mission on change triggered")
        Mission.onChange.subscribe(on: self) { (changed: (id: String, object: Mission?)) in
            if changed.id == "M1.Prologue",
                let mission = changed.object ?? Mission.get(id: changed.id),
                mission.name == "Prologue: On The Normandy" {
                expectationMissionOnChange.fulfill()
            }
        }

		var event1 = create(Event.self, from: prologueEventJson)
        var mission = create(Mission.self, from: prologueMissionJson)
        XCTAssert(mission?.name == "Prologue: On The Normandy", "Reported incorrect initial mission name")
        event1 = event1?.changed(isTriggered: true)
        mission = Mission.get(id: "M1.Prologue")
        XCTAssert(mission?.name == "Prologue: Find The Beacon", "Reported incorrect changed mission name")
        _ = event1?.changed(isTriggered: false)
        mission = Mission.get(id: "M1.Prologue")
        XCTAssert(mission?.name == "Prologue: On The Normandy", "Reported incorrect changed back mission name")

        // - wait for signal
        waitForExpectations(timeout: 0.1) { _ in }
        Mission.onChange.cancelSubscription(for: self)

        // #2 Event changes decision selection

        // - verify signal is fired
        let expectationDecisionOnChange = expectation(description: "Decision on change triggered")
        Decision.onChange.subscribe(on: self) { (changed: (id: String, object: Decision?)) in
            if changed.id == "D1.WrexArmor" {
                expectationDecisionOnChange.fulfill()
            }
        }

        let event2 = create(Event.self, from: wrexEventJson)
        var decision = create(Decision.self, from: wrexDecisionJson)
        XCTAssert(decision?.isSelected == false, "Reported incorrect initial decision")
        _ = event2?.changed(isTriggered: true)
        decision = Decision.get(id: "D1.WrexArmor")
        XCTAssert(decision?.isSelected == true, "Reported incorrect selected decision")

        // - wait for signal
        waitForExpectations(timeout: 0.1) { _ in }
        Decision.onChange.cancelSubscription(for: self)
	}

	/// Test Event dependent on others
	func testCombinedEvents() {
		initializeCurrentGame() // needed for saving event with game uuid
        let noveria1 = create(Event.self, from: noveria1Json)
        let noveria2 = create(Event.self, from: noveria2Json)
        var noveriaCombined = create(Event.self, from: noveriaCombinedJson)
		_ = create(Mission.self, from: noveriaCombinedMissionJson)

        let expectationMissionOnChange = expectation(description: "Mission on change triggered")
        Mission.onChange.subscribe(on: self) { (changed: (id: String, object: Mission?)) in
            if changed.id == "M1.Noveria.7Contamination",
                let mission = changed.object ?? Mission.get(id: changed.id),
                mission.isAvailable {
                expectationMissionOnChange.fulfill()
            }
        }

        XCTAssert(noveriaCombined?.isTriggered == false, "Reported incorrect initial event state")
        _ = noveria1?.changed(isTriggered: true)
        noveriaCombined = Event.get(id: "Noveria Peak 15 Repaired")
        XCTAssert(noveriaCombined?.isTriggered == false, "Reported incorrect initial event state")
        _ = noveria2?.changed(isTriggered: true)
        noveriaCombined = Event.get(id: "Noveria Peak 15 Repaired")
        XCTAssert(noveriaCombined?.isTriggered == true, "Reported incorrect triggered event state")

        waitForExpectations(timeout: 0.1) { _ in }
        Mission.onChange.cancelSubscription(for: self)
	}

    func testAdditiveEvents() {
        initializeCurrentGame() // needed for saving event with game uuid

        let eventBase = create(Event.self, from: additiveEventBase)
        let eventTarget = create(DataEvent.self, from: additiveEventTarget)
        let mission = create(Mission.self, from: additiveMission)

        _ = eventBase?.changed(isTriggered: true)
        sleep(2)
        _ = mission?.changed(isCompleted: true)

        let resultEvent = Event.get(id: eventTarget?.id ?? "")
        XCTAssertTrue(resultEvent?.isTriggered ?? false)
    }

}
