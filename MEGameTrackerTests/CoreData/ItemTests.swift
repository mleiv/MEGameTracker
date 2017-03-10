//
//  ItemTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/23/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class ItemTests: MEGameTrackerTests {

	// swiftlint:disable line_length

	let prologueMissionJson = "{\"id\": \"M1.Prologue\",\"sortIndex\": 1,\"gameVersion\": \"1\",\"missionType\": \"Mission\",\"name\": \"Prologue: On The Normandy\",\"aliases\": [\"Prologue: On The Normandy\", \"Prologue: Find The Beacon\"]}"

	let prologueMapJson = "{\"id\": \"G.Ear.Exo.Uto.Ede.A\",\"name\": \"Eden Prime Grounds\",\"isHidden\": true,\"referenceSize\": \"2083x2083\",\"image\": \"Detail_Maps\\/Game1\\/Eden_Prime\\/Eden_Prime_Grounds.pdf\",\"inMapId\": \"G.Ear.Exo.Uto.Eden\",\"mapType\":\"Area\",\"mapLocationPoint\": {\"x\": 150,\"y\": 650,\"width\": 1800,\"height\": 300},\"gameVersionData\": {\"1\": {\"isHidden\": false}},\"events\": [{\"type\": \"UnavailableInGame\",\"id\": \"Game3\"}]}"

	let prologueLoot1 = "{\"id\": \"M1.Prologue.Loot.I.1\",\"gameVersion\": \"1\",\"itemType\": \"MedKit\",\"itemDisplayType\": \"MedKit\",\"name\": \"MedKit 5\",\"inMapId\": \"G.Ear.Exo.Uto.Ede.A\",\"mapLocationPoint\": {\"x\": 455,\"y\": 895,\"radius\": 1}}"

	let prologueLoot2 = "{\"id\": \"M1.Prologue.Loot.I.2\",\"gameVersion\": \"1\",\"itemType\": \"Loot\",\"itemDisplayType\": \"Loot\",\"name\": \"Crate 2\",\"inMapId\": \"G.Ear.Exo.Uto.Ede.A\",\"mapLocationPoint\": {\"x\": 307,\"y\": 1199,\"radius\": 1}}"

	let prologueLoot3 = "{\"id\": \"M1.Prologue.Loot.I.4\",\"gameVersion\": \"1\",\"itemType\": \"Loot\",\"itemDisplayType\": \"Loot\",\"name\": \"Crate 4\",\"inMapId\": \"G.Ear.Exo.Uto.Ede.A\",\"mapLocationPoint\": {\"x\": 680,\"y\": 950,\"radius\": 1}}"

	let petsMissionJson = "{\"id\": \"A2.UC.Pets\",\"sortIndex\": 1000,\"gameVersion\": \"2\",\"missionType\": \"Collection\",\"name\": \"Pets\",\"description\": \"\",\"sideEffects\": \"Keeping the Prejek Paddlefish alive throughout Game 3 and New Game+ results in an Intel Bonus from Liara after the Mars Mission (10% Weapon or Power Damage). It also becomes a War Asset.\",\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Fish\", \"https:\\/\\/masseffect.wikia.com\\/wiki\\/Space_Hamster\"],\"events\": [{\"type\": \"BlockedUntil\",\"id\": \"Completed: Freedom\'s Progress\"}]}"

	let petsLootJson = "{\"id\": \"A2.UC.Pets.I.1SkaldFish\",\"gameVersion\": \"2\",\"itemType\": \"Pet\",\"itemDisplayType\": \"Novelty\",\"name\": \"Illium Skald Fish\",\"price\": \"-500 Credits\",\"inMapId\": \"G.C2.27.Souvenirs\",\"isShowInParentMap\": true,\"inMissionId\": \"A2.UC.Pets\"}"

	// swiftlint:enable line_length

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testEquality() {
		let item1 = create(Item.self, from: prologueLoot1)
		let item2 = create(Item.self, from: prologueLoot1)
		XCTAssert(item1 == item2, "Equality not working")
	}

	/// Test Item get methods.
	func testGetOne() {
		_ = create(Item.self, from: prologueLoot1)
		let item = Item.get(id: "M1.Prologue.Loot.I.1")
		XCTAssert(item?.name == "MedKit 5", "Failed to load by id")
	}

	/// Test Item getAll methods.
	func testGetAll() {
		_ = create(Item.self, from: prologueLoot1)
		_ = create(Item.self, from: prologueLoot2)
		_ = create(Item.self, from: prologueLoot3)
		let items = Item.getAll()
		XCTAssert(items.count == 3, "Failed to get all items")
	}

	/// Test Item sort method.
	func testSort() {
		_ = create(Item.self, from: prologueLoot3)
		_ = create(Item.self, from: prologueLoot1)
		_ = create(Item.self, from: prologueLoot2)
		// sort by id
		let matches1 = Item.getAll().sorted(by: Item.sort)
		XCTAssert(matches1[0].id == "M1.Prologue.Loot.I.1", "Failed to sort item 1 correctly")
		XCTAssert(matches1[1].id == "M1.Prologue.Loot.I.2", "Failed to sort item 2 correctly")
		XCTAssert(matches1[2].id == "M1.Prologue.Loot.I.4", "Failed to sort item 3 correctly")
	}

	/// Test Item game version variations
	func testGetByGameVersion() {
		initializeCurrentGame() // needed for game version

		_ = create(Item.self, from: prologueLoot3)
		_ = create(Item.self, from: prologueLoot1)
		_ = create(Item.self, from: petsLootJson)
		let matches1 = Item.getAll(gameVersion: .game1)
		XCTAssert(matches1.count == 2, "Failed to get all game 1 items")
		let matches2 = Item.getAll(gameVersion: .game2)
		XCTAssert(matches2.count == 1, "Failed to get all game 2 items")
	}

	/// Test Items loaded by their parent mission
	func testGetByMission() {
		_ = create(Item.self, from: prologueLoot1)
		let mission1 = create(Mission.self, from: prologueMissionJson)
		let objectives1 = mission1?.getObjectives()
		XCTAssert(objectives1?.isEmpty == true, "Incorrectly loaded loot as a mission objective")

		let item2 = create(Item.self, from: petsLootJson)
		let mission2 = create(Mission.self, from: petsMissionJson)
		let objectives2 = mission2?.getObjectives()
		XCTAssert(objectives2?.count == 1, "Failed to get mission item objectives")
		XCTAssert(objectives2?.first as? Item == item2, "Failed to load item as mission objective")
	}

	/// Test Items loaded by their parent map
	func testGetByMap() {
		_ = create(Item.self, from: prologueLoot1)
		_ = create(Item.self, from: prologueLoot2)
		_ = create(Item.self, from: prologueLoot3)
		let map = create(Map.self, from: prologueMapJson)
		let locations = map?.getMapLocations() ?? []
		XCTAssert(locations.count == 3, "Failed to get all map items")
	}

	/// Test Item change action.
	func testChange() {
		initializeCurrentGame() // needed for saving with game uuid

		// - verify signal is fired
		let expectationItemAcquired = expectation(description: "Item on change triggered")
		Item.onChange.subscribe(on: self) { (changed: (id: String, object: Item?)) in
			if changed.id == "M1.Prologue.Loot.I.1",
				let item = changed.object ?? Item.get(id: changed.id),
				item.isAcquired {
				expectationItemAcquired.fulfill()
			}
		}

		var item = create(Item.self, from: prologueLoot1)
		XCTAssert(item?.isAcquired == false, "Reported incorrect initial item state")
		item?.change(isAcquired: true, isSave: true)
		let item2 = Item.get(id: "M1.Prologue.Loot.I.1")
		XCTAssert(item2?.isAcquired == true, "Reported incorrect acquired item state")

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		Item.onChange.cancelSubscription(for: self)
	}
}
