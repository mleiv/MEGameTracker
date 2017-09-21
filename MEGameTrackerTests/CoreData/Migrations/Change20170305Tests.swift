//
//  Change20170305Tests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/31/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class Change20170305Tests: MEGameTrackerTests {

	// swiftlint:disable line_length

	let missionFrom = "{\"id\": \"M3.0.Citadel1\",\"gameVersion\": \"3\",\"missionType\": \"Mission\",\"name\": \"Priority: The Citadel I\", \"conversationRewards\": [{\"set\": {\"context\": \"Recruiting Dr. Michel\",\"isExclusiveSet\": true,\"options\": [{\"id\": \"M3.0.Citadel1.P4\",\"type\": \"Paragon\",\"value\": 2,\"trigger\": \"\\\"Save billions, not hundreds.\\\"\"}, {\"id\": \"M3.0.Citadel1.R4\",\"type\": \"Renegade\",\"value\": 2,\"trigger\": \"\\\"Our mission is more important.\\\"\"}]}}, {\"context\": \"Visiting Ashley\\/Kaidan at the hospital\",\"id\": \"M3.0.Citadel1.PR5\",\"type\": \"Paragade\",\"value\": 2,\"trigger\": \"(Automatic.)\"}, {\"set\": {\"context\": \"Speaking to Bailey at office\",\"isExclusiveSet\": true,\"options\": [{\"id\": \"M3.0.Citadel1.P6\",\"type\": \"Paragon\",\"value\": 2,\"trigger\": \"\\\"Bear with it.\\\"\"}, {\"id\": \"M3.0.Citadel1.R6\",\"type\": \"Renegade\",\"value\": 2,\"trigger\": \"(Automatic)\"}]}}]}"

	let ashleyConvo = "{\"id\": \"A3.Convo.S.Ashley\",\"gameVersion\": \"3\",\"missionType\": \"Conversation\",\"name\": \"Ashley Williams\", \"conversationRewards\": [{\"context\": \"Visiting Ashley at the hospital (during Citadel I)\",\"id\": \"A3.Convo.S.Ashley.P1\",\"type\": \"Paragade\",\"value\": 2,\"trigger\": \"(Automatic)\"}]}"

	let kaidanConvo = "{\"id\": \"A3.Convo.S.Kaidan\",\"gameVersion\": \"3\",\"missionType\": \"Conversation\",\"name\": \"Kaidan Alenko\", \"conversationRewards\": [{\"context\": \"Visiting Kaidan at the hospital (during Citadel I)\",\"id\": \"A3.Convo.S.Kaidan.P1\",\"type\": \"Paragade\",\"value\": 2,\"trigger\": \"(Automatic)\"}]}"

	let michelConvo = "{\"id\": \"A3.Convo.C.Michel\",\"gameVersion\": \"3\",\"missionType\": \"Conversation\",\"name\": \"Dr. Michel\",\"conversationRewards\": [{\"set\": {\"context\": \"Speaking to Dr. Michel at the hospital (Citadel I)\",\"options\": [{\"id\": \"A3.Convo.C.Michel.P1\",\"type\": \"Paragade\",\"value\": 2,\"trigger\": \"(Automatic)\"}, {\"set\": {\"context\": \"Recruit Dr. Michel\",\"isExclusiveSet\": true,\"options\": [{\"id\": \"A3.Convo.C.Michel.P2\",\"type\": \"Paragon\",\"value\": 2,\"trigger\": \"\\\"Save billions, not hundreds.\\\"\"}, {\"id\": \"A3.Convo.C.Michel.R2\",\"type\": \"Renegade\",\"value\": 2,\"trigger\": \"\\\"Our mission is more important.\\\"\"}]}}]}}]}"

	let saveAshleyJson = "{\"id\": \"D1.Ashley\",\"gameVersion\": \"1\",\"name\": \"Saved Ashley Williams on Virmire\",\"description\": \"If you save Ashley, she will play a key role in Games 2 and 3.\",\"blocksDecisionIds\": [\"D1.Kaidan\"],\"sortIndex\": 203}"

	let saveKaidanJson = "{\"id\": \"D1.Kaidan\",\"gameVersion\": \"1\",\"name\": \"Saved Kaidan Alenko on Virmire\",\"description\": \"If you save Kaidan, he will play a key role in Games 2 and 3.\",\"blocksDecisionIds\": [\"D1.Ashley\"],\"sortIndex\": 203}"

	// swiftlint:enable line_length

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	/// Test migrating a decision
	func testMoveConversation() {
		initializeCurrentGame() // needed for saving with game uuid

		var fromMission = create(Mission.self, from: missionFrom)
		_ = create(Mission.self, from: michelConvo)
		_ = fromMission?.changed(conversationRewardId: "M3.0.Citadel1.R4", isSelected: true)

        App.current.lastBuild = 1 // required to run
		Change20170305().run()

		fromMission = Mission.get(id: "M3.0.Citadel1")
		let toMission = Mission.get(id: "A3.Convo.C.Michel")
		XCTAssert(
			toMission?.conversationRewards.selectedIds().contains("A3.Convo.C.Michel.R2") == true,
			"Michel's conversation not migrated"
		)
		XCTAssert(
			fromMission?.conversationRewards.selectedIds().contains("M3.0.Citadel1.R4") == false,
			"Source conversation not migrated"
		)
	}

	/// Test migrating Ashley/Kaidan conversation (special case)
	func testAshleyKaidanConversation() {
		initializeCurrentGame() // needed for saving with game uuid

		var decision1 = create(Decision.self, from: saveAshleyJson)
		_ = create(Decision.self, from: saveKaidanJson)
		decision1 = decision1?.changed(isSelected: true)
		var fromMission = create(Mission.self, from: missionFrom)
		_ = create(Mission.self, from: ashleyConvo)
		_ = create(Mission.self, from: kaidanConvo)
		_ = fromMission?.changed(conversationRewardId: "M3.0.Citadel1.PR5", isSelected: true)

        App.current.lastBuild = 1 // required to run
		Change20170305().run()

		fromMission = Mission.get(id: "M3.0.Citadel1")
		let toMission = Mission.get(id: "A3.Convo.S.Ashley")
		let notToMission = Mission.get(id: "A3.Convo.S.Kaidan")
		XCTAssert(
			toMission?.conversationRewards.selectedIds().contains("A3.Convo.S.Ashley.P1") == true,
			"Ashley's conversation not migrated"
		)
		XCTAssert(
			fromMission?.conversationRewards.selectedIds().contains("M3.0.Citadel1.PR5") == false,
			"Source conversation not migrated"
		)
		XCTAssert(
			notToMission?.conversationRewards.selectedIds().contains("A3.Convo.S.Kaidan.P1") == false,
			"Kaidan's conversation incorrectly migrated"
		)
	}

}
