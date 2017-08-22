//
//  GameSequenceTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/23/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class GameSequenceTests: MEGameTrackerTests {

	// swiftlint:disable line_length

	/// A saved game with no saved shepards.
	let gameNoShepardJson = "{\"createdDate\" : \"2017-02-26 08:13:28\",\"modifiedDate\" : \"2017-02-26 08:17:50\",\"uuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29518\"}"

	/// A saved game with no saved shepards.
	let gameNoShepardLaterDateJson = "{\"createdDate\" : \"2017-02-28 08:13:28\",\"modifiedDate\" : \"2017-02-28 08:17:50\",\"uuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29517\"}"

	/// A game with no specified shepard, but two shepards attached to it (below).
	let gameUnknownShepardJson = "{\"createdDate\" : \"2017-02-26 08:13:28\",\"modifiedDate\" : \"2017-02-26 08:17:50\",\"uuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\"}"

	/// Same uuid as above, but with shepard specified.
	/// Note: this is NOT a unique game.
	let gameWithShepardJson = "{\"createdDate\" : \"2017-02-26 08:13:28\",\"lastPlayedShepard\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFD\",\"modifiedDate\" : \"2017-02-26 08:17:50\",\"uuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\"}"

	/// The uuid of the two identical games above.
	let femShepGameUuid = UUID(uuidString: "7BF05BF6-386A-4429-BC18-2A60F2D29519")!

	/// Game 1 Shepard attached to game sequence above.
	let femShep1Json = "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFD\",\"gameVersion\" : \"1\",\"paragon\" : 0,\"createdDate\" : \"2017-02-15 07:40:32\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-23 07:13:39\",\"origin\" : \"Earthborn\",\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"

	/// Game 2 Shepard attached to game sequence above.
	let femShep2Json = "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFE\",\"gameVersion\" : \"2\",\"paragon\" : 0,\"createdDate\" : \"2017-02-25 09:10:15\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-25 09:10:15\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"

	/// Game 3 Shepard attached to no game sequence (should not return in searches).
	let broShep3Json = "{\"uuid\" : \"B6D0BD56-9CA9-4060-8F2E-E4DFE4EEE8A2\",\"gameVersion\" : \"3\",\"paragon\" : 0,\"createdDate\" : \"2017-02-26 01:59:19\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29520\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-26 05:15:40\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"432.FLC.JCI.F6F.JHI.I7I.JHK.4KE.FJ8.HH7.216.5\",\"class\" : \"Soldier\",\"gender\" : \"M\",\"name\" : \"John\"}"

	// swiftlint:enable line_length

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testEquality() {
		let game1 = create(GameSequence.self, from: gameNoShepardJson)
		let game2 = create(GameSequence.self, from: gameNoShepardJson)
		XCTAssert(game1 == game2, "Equality not working")
	}

	/// Test GameSequence get methods.
	func testGetOne() {
		// setup
		let game = create(GameSequence.self, from: gameNoShepardJson)
		// we turned off cascade save in our custom create() above, so explicitly save shepard:
		if var shepard = game?.shepard {
			_ = shepard.save(isAllowDelay: false)
		}

		// Test loading a game sequence with no shepard saved
        let uuid = UUID(uuidString: "7BF05BF6-386A-4429-BC18-2A60F2D29518")!
		let game1 = GameSequence.get(uuid: uuid)
		XCTAssert(game1?.uuid == uuid, "Failed to load by id")
		XCTAssert(game1?.getAllShepards().count == 1, "Incorrect initial game shepard count")
        XCTAssert(game1?.shepard?.gameVersion == .game1, "Incorrect initial game shepard version")
        XCTAssert(game1?.shepard?.gender == .male, "Incorrect initial game shepard gender")

        // more setup
        _ = create(Shepard.self, from: femShep1Json)
        _ = create(Shepard.self, from: femShep2Json)
        _ = create(Shepard.self, from: broShep3Json)

        // Test loading a game sequence with shepards
        _ = create(GameSequence.self, from: gameWithShepardJson)
        let game2 = GameSequence.get(uuid: femShepGameUuid)
        XCTAssert(game2?.uuid == femShepGameUuid, "Failed to load by id")
        XCTAssert(game2?.getAllShepards().count == 2, "Incorrect game shepard count")
        XCTAssert(game2?.shepard?.fullName == "Xoe Shepard", "Incorrect game shepard")
	}

	/// Test GameSequence get last played shepard
	func testGetShepardByLastPlayed() {
		// setup
		_ = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)
		_ = create(Shepard.self, from: broShep3Json)

		// Test loading a game sequence with shepards, but none saved to game
		_ = create(GameSequence.self, from: gameUnknownShepardJson)
		let game1 = GameSequence.get(uuid: femShepGameUuid)
		XCTAssert(game1?.shepard?.gameVersion == .game2, "Incorrect game shepard last played by date")

		// Test loading a game sequence with shepards, and one specified as last played
		_ = create(GameSequence.self, from: gameWithShepardJson)
		let game2 = GameSequence.get(uuid: femShepGameUuid)
		XCTAssert(game2?.shepard?.gameVersion == .game1, "Incorrect game shepard last played by uuid")
	}

	/// Test GameSequence get last played
	func testGetByLastPlayed() {
		// setup
		_ = create(GameSequence.self, from: gameNoShepardJson)
		_ = create(GameSequence.self, from: gameNoShepardLaterDateJson)
		let game = GameSequence.lastPlayed()
        let uuid = UUID(uuidString: "7BF05BF6-386A-4429-BC18-2A60F2D29517")!
		XCTAssert(game?.uuid == uuid, "Incorrect last played game")
	}

	/// Test GameSequence getAll methods.
	func testGetAll() {
		_ = create(GameSequence.self, from: gameNoShepardJson)
		_ = create(GameSequence.self, from: gameWithShepardJson)
		let games = GameSequence.getAll()
		XCTAssert(games.count == 2, "Failed to get all games")
	}

	/// Test GameSequence change action.
	func testChangeNew() {
		initializeCurrentGame() // make a new game
		let uuid = App.current.game?.shepard?.uuid
		App.current.game?.change(gameVersion: .game2)
		XCTAssert(App.current.game?.shepard?.gameVersion == .game2, "Failed to change game version")
		guard let uuid2 = App.current.game?.shepard?.uuid else {
			XCTAssert(false, "Failed to save new game version")
			return
		}
		XCTAssert(uuid2 != uuid, "Incorrect game shepard")
		let shepard2 = Shepard.get(uuid: uuid2)
		XCTAssert(shepard2?.uuid == uuid2, "Failed to save new game version")
	}

	/// Test GameSequence change action.
	func testChangeExisting() {
		_ = create(Shepard.self, from: femShep1Json)
		_ = create(Shepard.self, from: femShep2Json)
		var game = create(GameSequence.self, from: gameWithShepardJson)

		XCTAssert(game?.shepard?.gameVersion == .game1, "Incorrect initial game shepard")
		game?.change(gameVersion: .game2)
		XCTAssert(game?.shepard?.gameVersion == .game2, "Failed to change game version")
        let uuid = UUID(uuidString: "BC0D3009-3385-4132-851A-DF472CBF9EFE")!
		XCTAssert(game?.shepard?.uuid == uuid, "Incorrect game shepard")
	}
}
