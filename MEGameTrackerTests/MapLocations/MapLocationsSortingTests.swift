//
//  MapLocationsSortingTests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 5/15/2016.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class MapLocationsSortingTests: MEGameTrackerTests {

	// swiftlint:disable line_length

	let testUuid = UUID()
	var blockingEventId: String { return "Blocking\(testUuid)" }
	var missions: [Mission] = []

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		_ = Event.deleteAll()
		_ = Mission.deleteAll()
		super.tearDown()
	}

	func testIdSort() {
		guard let baseMission = create(DataMission.self, from: "{\"id\":\"M1.1\",\"gameVersion\":\"1\",\"name\":\"Some Mission\",\"missionType\":\"Mission\"}")
		else {
			XCTAssert(false, "Could not initialize DataMission base")
			return
		}
		let mission1 = Mission(id: "M1.1", generalData: baseMission)
		let mission2 = Mission(id: "M1.2", generalData: baseMission) // its fine that ids don't match
		let mission3 = Mission(id: "M1.3", generalData: baseMission)
		let mission4 = Mission(id: "M1.4", generalData: baseMission)
		let mission5 = Mission(id: "M1.5", generalData: baseMission)

		let missions: [Mission] = [mission5, mission2, mission1, mission4, mission3].sorted(by: Mission.sort)
		XCTAssert(missions[0] == mission1, "Invalid sort index 1")
		XCTAssert(missions[1] == mission2, "Invalid sort index 2")
		XCTAssert(missions[2] == mission3, "Invalid sort index 3")
		XCTAssert(missions[3] == mission4, "Invalid sort index 4")
		XCTAssert(missions[4] == mission5, "Invalid sort index 5")
	}

	func testMissionTypeSort() {
		guard let mission1 = create(Mission.self, from: "{\"id\":\"M1.1\",\"gameVersion\":\"1\",\"name\":\"Some Mission 1\",\"missionType\":\"Mission\"}"),
			let mission2 = create(Mission.self, from: "{\"id\":\"M1.2\",\"gameVersion\":\"1\",\"name\":\"Some Mission 2\",\"missionType\":\"Assignment\"}"),
			let mission3 = create(Mission.self, from: "{\"id\":\"M1.3\",\"gameVersion\":\"1\",\"name\":\"Some Mission 3\",\"missionType\":\"Objective\"}")//,
//			let mission4 = create(Mission.self, from: "{\"id\":\"M1.4\",\"gameVersion\":\"1\",\"name\":\"Some Mission 4\",\"missionType\":\"Objective\"}"), // Collection
//			let mission5 = create(Mission.self, from: "{\"id\":\"M1.5\",\"gameVersion\":\"1\",\"name\":\"Some Mission 5\",\"missionType\":\"Objective\"}") //DLC
		else {
			XCTAssert(false, "Could not initialize DataMission base")
			return
		}

		let missions: [Mission] = [mission2, mission1, mission3].sorted(by: MapLocation.sort).flatMap({ $0 as Mission })
//		let missions = [mission5, mission2, mission1, mission4, mission3].sort(Mission.sort)
		XCTAssert(missions[0] == mission1, "Invalid sort index 1")
		XCTAssert(missions[1] == mission2, "Invalid sort index 2")
		XCTAssert(missions[2] == mission3, "Invalid sort index 3")
//		XCTAssert(missions[3] == mission4, "Invalid sort index 4")
//		XCTAssert(missions[4] == mission5, "Invalid sort index 5")
	}

	func testSortIndexSort() {
		guard let mission1 = create(Mission.self, from: "{\"id\":\"M1.1\",\"gameVersion\":\"1\",\"name\":\"Some Mission 1\",\"missionType\":\"Mission\",\"sortIndex\":5}"),
			let mission2 = create(Mission.self, from: "{\"id\":\"M1.2\",\"gameVersion\":\"1\",\"name\":\"Some Mission 2\",\"missionType\":\"Mission\",\"sortIndex\":4}"),
			let mission3 = create(Mission.self, from: "{\"id\":\"M1.3\",\"gameVersion\":\"1\",\"name\":\"Some Mission 3\",\"missionType\":\"Mission\",\"sortIndex\":3}"),
			let mission4 = create(Mission.self, from: "{\"id\":\"M1.4\",\"gameVersion\":\"1\",\"name\":\"Some Mission 4\",\"missionType\":\"Mission\",\"sortIndex\":2}"),
			let mission5 = create(Mission.self, from: "{\"id\":\"M1.5\",\"gameVersion\":\"1\",\"name\":\"Some Mission 5\",\"missionType\":\"Mission\",\"sortIndex\":1}")
		else {
			XCTAssert(false, "Could not initialize DataMission base")
			return
		}

		let missions: [Mission] = [mission5, mission2, mission1, mission4, mission3].sorted(by: Mission.sort)
		XCTAssert(missions[0] == mission5, "Invalid sort index 1")
		XCTAssert(missions[1] == mission4, "Invalid sort index 2")
		XCTAssert(missions[2] == mission3, "Invalid sort index 3")
		XCTAssert(missions[3] == mission2, "Invalid sort index 4")
		XCTAssert(missions[4] == mission1, "Invalid sort index 5")
	}

	func testGameVersionSort() {
		guard let mission1 = create(Mission.self, from: "{\"id\":\"M1.1\",\"gameVersion\":\"1\",\"name\":\"Some Mission 1\",\"missionType\":\"Mission\"}"),
			let mission2 = create(Mission.self, from: "{\"id\":\"M1.2\",\"gameVersion\":\"3\",\"name\":\"Some Mission 2\",\"missionType\":\"Mission\"}"),
			let mission3 = create(Mission.self, from: "{\"id\":\"M1.3\",\"gameVersion\":\"2\",\"name\":\"Some Mission 3\",\"missionType\":\"Mission\"}")
		else {
			XCTAssert(false, "Could not initialize DataMission base")
			return
		}

		let missions: [Mission] = [mission2, mission1, mission3].sorted(by: Mission.sort)
		XCTAssert(missions[0] == mission1, "Invalid sort index 1")
		XCTAssert(missions[1] == mission3, "Invalid sort index 2")
		XCTAssert(missions[2] == mission2, "Invalid sort index 3")
	}

	func testAvailabilitySort() {
		createDependentEvent()
		guard let mission1 = create(Mission.self, from: "{\"id\":\"M1.1\",\"gameVersion\":\"1\",\"name\":\"Some Mission 1\",\"missionType\":\"Mission\",\"events\":[{\"type\":\"BlockedUntil\",\"id\":\"\(blockingEventId)\"}]}"),
			let mission2 = create(Mission.self, from: "{\"id\":\"M1.2\",\"gameVersion\":\"1\",\"name\":\"Some Mission 2\",\"missionType\":\"Mission\"}"),
			let mission3 = create(Mission.self, from: "{\"id\":\"M1.3\",\"gameVersion\":\"1\",\"name\":\"Some Mission 3\",\"missionType\":\"Mission\"}")
		else {
			XCTAssert(false, "Could not initialize DataMission base")
			return
		}

		let missions: [Mission] = [mission2, mission1, mission3].sorted(by: Mission.sort)
		XCTAssert(missions[0] == mission2, "Invalid sort index 1")
		XCTAssert(missions[1] == mission3, "Invalid sort index 2")
		XCTAssert(missions[2] == mission1, "Invalid sort index 3")
	}

	func testCompletedSort() {
		guard let mission1 = create(Mission.self, from: "{\"id\":\"M1.1\",\"gameVersion\":\"1\",\"name\":\"Some Mission 1\",\"missionType\":\"Mission\"}"),
			let mission2 = create(Mission.self, from: "{\"id\":\"M1.2\",\"gameVersion\":\"1\",\"name\":\"Some Mission 2\",\"missionType\":\"Mission\"}"),
			let mission3 = create(Mission.self, from: "{\"id\":\"M1.3\",\"gameVersion\":\"1\",\"name\":\"Some Mission 3\",\"missionType\":\"Mission\"}")
		else {
			XCTAssert(false, "Could not initialize DataMission base")
			return
		}
		_ = mission1.changed(isCompleted: true, isSave: false)

		let missions: [Mission] = [mission2, mission1, mission3].sorted(by: Mission.sort)
		XCTAssert(missions[0] == mission2, "Invalid sort index 1")
		XCTAssert(missions[1] == mission3, "Invalid sort index 2")
		XCTAssert(missions[2] == mission1, "Invalid sort index 3")
	}

	func testCombinationSort() {
		createDependentEvent()
		guard let mission1 = create(Mission.self, from: "{\"id\":\"M1.1\",\"gameVersion\":\"1\",\"name\":\"Some Mission 1\",\"missionType\":\"Mission\",\"sortIndex\":3,\"events\":[{\"type\":\"BlockedUntil\",\"id\":\"\(blockingEventId)\"}]}"),
			let mission2 = create(Mission.self, from: "{\"id\":\"M1.2\",\"gameVersion\":\"2\",\"name\":\"Some Mission 2\",\"missionType\":\"Mission\",\"sortIndex\":3}"),
			let mission3 = create(Mission.self, from: "{\"id\":\"M1.3\",\"gameVersion\":\"3\",\"name\":\"Some Mission 3\",\"missionType\":\"Mission\",\"sortIndex\":3}"),
			let mission4 = create(Mission.self, from: "{\"id\":\"M1.4\",\"gameVersion\":\"1\",\"name\":\"Some Mission 4\",\"missionType\":\"Assignment\",\"sortIndex\":3}"),
			let mission5 = create(Mission.self, from: "{\"id\":\"M1.5\",\"gameVersion\":\"1\",\"name\":\"Some Mission 5\",\"missionType\":\"Objective\",\"sortIndex\":3}"),
			let mission6 = create(Mission.self, from: "{\"id\":\"M1.6\",\"gameVersion\":\"1\",\"name\":\"Some Mission 6\",\"missionType\":\"Mission\",\"sortIndex\":1}"),
			let mission7 = create(Mission.self, from: "{\"id\":\"M1.7\",\"gameVersion\":\"1\",\"name\":\"Some Mission 7\",\"missionType\":\"Assignment\",\"sortIndex\":1}"),
			let mission8 = create(Mission.self, from: "{\"id\":\"M1.8\",\"gameVersion\":\"1\",\"name\":\"Some Mission 8\",\"missionType\":\"Mission\",\"sortIndex\":3}")
		else {
			XCTAssert(false, "Could not initialize DataMission base")
			return
		}
		_ = mission6.changed(isCompleted: true, isSave: false)

		let missions: [Mission] = [mission5, mission2, mission1, mission4, mission3, mission8, mission6, mission7].sorted(by: Mission.sort)
		XCTAssert(missions[0] == mission8, "Invalid sort index 1") // mission type
		XCTAssert(missions[1] == mission7, "Invalid sort index 2") // assignment + sortIndex
		XCTAssert(missions[2] == mission4, "Invalid sort index 3") // assignment
		XCTAssert(missions[3] == mission5, "Invalid sort index 4") // objective
		XCTAssert(missions[4] == mission1, "Invalid sort index 5") // unavailable
		XCTAssert(missions[5] == mission6, "Invalid sort index 6") // completed
		XCTAssert(missions[6] == mission2, "Invalid sort index 7") // game 2
		XCTAssert(missions[7] == mission3, "Invalid sort index 8") // game 3
	}

	private func createDependentEvent() {
		var event = create(DataEvent.self, from: "{\"id\":\"\(blockingEventId)\"}")
		_ = event?.save()
		XCTAssert(Event.get(id: event?.id ?? "") != nil, "Failed to create blocking event")
	}

	// swiftlint:enable line_length
}
