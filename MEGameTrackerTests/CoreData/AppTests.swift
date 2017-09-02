//
//  AppTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/26/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class AppTests: MEGameTrackerTests {

	// swiftlint:disable line_length

	let appNoRecentJson = "{\"currentGameUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\"}"

	let appWithRecentJson = "{\"currentGameUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"recentlyViewedMissions\" : {\"1\" : {\"maxElements\" : 20,\"list\" : [{\"id\" : \"A1.UC.TurianInsignias\",\"date\" : \"2017-02-27 03:20:54\"},{\"id\" : \"M1.Garrus\",\"date\" : \"2017-02-27 03:20:49\"}]}},\"recentlyViewedMaps\" : {\"maxElements\" : 20,\"list\" : [{\"id\" : \"G.Ear.Exodus\",\"date\" : \"2017-02-27 03:19:38\"}]}}"

	/// Same uuid as above, but with shepard specified.
	/// Note: this is NOT a unique game.
	let gameWithShepardJson = "{\"createdDate\" : \"2017-02-26 08:13:28\",\"lastPlayedShepard\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFD\",\"modifiedDate\" : \"2017-02-26 08:17:50\",\"uuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\"}"

	let game2Json = "{\"createdDate\" : \"2017-02-27 08:13:28\",\"modifiedDate\" : \"2017-02-27 08:17:50\",\"uuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29520\"}"

	/// The uuid of the two identical games above.
	let femShepGameUuid = UUID(uuidString: "7BF05BF6-386A-4429-BC18-2A60F2D29519")

	/// Game 1 Shepard attached to game sequence above.
	let femShep1Json = "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFD\",\"gameVersion\" : \"1\",\"paragon\" : 0,\"createdDate\" : \"2017-02-15 07:40:32\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-23 07:13:39\",\"origin\" : \"Earthborn\",\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"

	/// Game 2 Shepard attached to game sequence above.
	let femShep2Json = "{\"uuid\" : \"BC0D3009-3385-4132-851A-DF472CBF9EFE\",\"gameVersion\" : \"2\",\"paragon\" : 0,\"createdDate\" : \"2017-02-25 09:10:15\",\"level\" : 1,\"gameSequenceUuid\" : \"7BF05BF6-386A-4429-BC18-2A60F2D29519\",\"reputation\" : \"Sole Survivor\",\"renegade\" : 0,\"modifiedDate\" : \"2017-02-25 09:10:15\",\"origin\" : \"Earthborn\",\"isSavedToCloud\" : false,\"appearance\" : \"XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.XXX.X\",\"class\" : \"Soldier\",\"gender\" : \"F\",\"name\" : \"Xoe\"}"

	let garrusJson = "{\"id\": \"M1.Garrus\",\"sortIndex\": 3,\"gameVersion\": \"1\",\"missionType\": \"Mission\",\"name\": \"Citadel: Garrus\",\"isOptional\": true,\"inMapId\": \"G.C1.Tower\",\"mapLocationPoint\": {\"x\": 1049,\"y\": 571,\"radius\": true},\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Citadel:_Expose_Saren#Report_to_the_Council\"],\"relatedMissionIds\": [\"M1.ExposeSaren\", \"M1.ShadowBroker\"]}"

	let insigniasJson = "{\"id\": \"A1.UC.TurianInsignias\",\"sortIndex\": 45,\"gameVersion\": \"1\",\"missionType\": \"Collection\",\"name\": \"UNC: Turian Insignias\",\"aliases\": [\"UNC: Turian Insignias\", \"UNC: Collection Complete\"],\"objectivesCountToCompletion\": 2,\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/UNC:_Turian_Insignias\"]}"

	let exodusJson = "{\"id\": \"G.Ear.Exodus\", \"name\": \"Exodus Cluster\", \"inMapId\": \"G.Base\", \"rerootBreadcrumbs\": true, \"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster1.pdf\",\"referenceSize\": \"2083x2083\", \"mapType\": \"Cluster\", \"mapLocationPoint\": {\"x\": 2417, \"y\": 3100, \"radius\": 30}, \"annotationNote\": \"Utopia, Asgard\", \"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Exodus_Cluster\"], \"gameVersionData\": {\"2\": {\"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster2.pdf\"}, \"3\": {\"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster3.pdf\"}},\"events\": [{\"type\": \"UnavailableInGame\", \"id\": \"Game2\"}]}"

	let digJson = "{\"id\": \"A2.N7.ArcheologicalDig\",\"sortIndex\": 10,\"gameVersion\": \"2\",\"missionType\": \"Assignment\",\"name\": \"N7: Archeological Dig Site\",\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/N7:_Archeological_Dig_Site\"],\"events\": [{\"type\": \"Triggers\",\"id\": \"Completed: Joab Prothean Pyramid\"}]}"

	// swiftlint:enable line_length

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testEquality() {
		let app1 = App()
		let app2 = app1
		XCTAssert(app1 == app2, "Equality not working")
	}

	/// Test App create methods.
	func testCreate() {
		_ = create(App.self, from: "{}") // reset
		App.retrieve()

		guard let uuid = App.current.currentGameUuid,
			let game = GameSequence.get(uuid: uuid),
			game.uuid == uuid else {
			XCTAssert(false, "Newly created game not saved")
			return
		}
		XCTAssert(App.current.recentlyViewedMaps.contents.isEmpty,
			"Initialized recently viewed maps not empty")
		XCTAssert(App.current.recentlyViewedMissions[.game1]?.contents.count == 0,
			"Initialized recently viewed missions not empty")
	}

	/// Test App get methods.
	func testGet() {
		_ = create(GameSequence.self, from: game2Json)
		_ = create(GameSequence.self, from: gameWithShepardJson)

		// Get a saved game identified by the app
		_ = create(App.self, from: appNoRecentJson)
		App.retrieve()
		XCTAssert(App.current.game?.uuid == femShepGameUuid,
			"Failed to load correct game version")

		// Get the last saved game
		_ = create(App.self, from: "{}")
		App.retrieve()
		XCTAssert(App.current.game?.uuid != femShepGameUuid,
			"Failed to load correct game version")
	}

	/// Test App event signals.
	func testAppEvents() {
        // #1 Test app open calls onchange once

        // - verify signal is fired
        let expectationShepardChanged1 = expectation(description: "Shepard on change triggered")
        App.onCurrentShepardChange.subscribe(on: self) { _ in
            expectationShepardChanged1.fulfill()
        }

        _ = create(App.self, from: "{}") // reset
        App.retrieve()

        // - wait for signal
        waitForExpectations(timeout: 0.1) { _ in }
        App.onCurrentShepardChange.cancelSubscription(for: self)

		// #2 Test app open with saved data calls onchange once

		// - verify signal is fired
		let expectationShepardChanged2 = expectation(description: "Shepard on change triggered")
		App.onCurrentShepardChange.subscribe(on: self) { _ in
			expectationShepardChanged2.fulfill()
		}

        _ = create(Map.self, from: exodusJson)
        _ = create(Mission.self, from: garrusJson)
        _ = create(Mission.self, from: insigniasJson)
        _ = create(GameSequence.self, from: gameWithShepardJson)
		_ = create(App.self, from: appWithRecentJson)
		App.retrieve()

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		App.onCurrentShepardChange.cancelSubscription(for: self)

        // #3 Test change game version calls onchange once

        // - verify signal is fired
        let expectationShepardChanged3 = expectation(description: "Shepard on change triggered")
        App.onCurrentShepardChange.subscribe(on: self) { _ in
            expectationShepardChanged3.fulfill()
        }

        App.current.changeGame(isSave: false) { game in
            var game = game
            game?.change(gameVersion: .game2)
            return game
        }

        // - wait for signal
        waitForExpectations(timeout: 0.1) { _ in }
        App.onCurrentShepardChange.cancelSubscription(for: self)

		// #4 Test change shepard calls onchange once

		// - verify signal is fired
		let expectationShepardChanged4 = expectation(description: "Shepard on change triggered")
		App.onCurrentShepardChange.subscribe(on: self) { _ in
			expectationShepardChanged4.fulfill()
		}

        App.current.changeGame(isSave: false, isNotify: false) { game in
            var game = game
            game?.shepard = game?.shepard?.changed(name: "Javier") // let shepard manage its own isNotify
            return game
        }

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		App.onCurrentShepardChange.cancelSubscription(for: self)

		// #5 Test change game calls onchange once

		// - verify signal is fired
		let expectationShepardChanged5 = expectation(description: "Shepard on change triggered")
		App.onCurrentShepardChange.subscribe(on: self) { _ in
			expectationShepardChanged5.fulfill()
		}

		guard var game = create(GameSequence.self, from: game2Json) else {
			XCTAssert(false, "Failed to load game from json")
			return
		}
        _ = game.saveAnyChanges(isAllowDelay: false)
        App.current.changeGame(isSave: false) { _ in game }

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		App.onCurrentShepardChange.cancelSubscription(for: self)
	}

	/// Test App get recently viewed methods.
	func testGetRecentlyViewed() {
		_ = create(Map.self, from: exodusJson)
		_ = create(Mission.self, from: garrusJson)
		_ = create(Mission.self, from: insigniasJson)
		_ = create(GameSequence.self, from: gameWithShepardJson)
		_ = create(App.self, from: appWithRecentJson)
		App.retrieve()
		XCTAssert(App.current.recentlyViewedMissions[.game1]?.contents.count == 2,
			"Failed to load recently viewed missions")
		XCTAssert(App.current.recentlyViewedMaps.contents.count == 1,
			"Failed to load recently viewed maps")
	}

	/// Test App get recently viewed methods.
	func testGetRecentlyViewedMissionsByGameVersion() {
		_ = create(Mission.self, from: garrusJson)
		_ = create(Mission.self, from: digJson)
		_ = create(GameSequence.self, from: gameWithShepardJson)
		_ = create(App.self, from: appNoRecentJson)
		App.retrieve()
		App.current.addRecentlyViewedMission(missionId: "M1.Garrus", gameVersion: .game1)
		App.current.addRecentlyViewedMission(missionId: "A2.N7.ArcheologicalDig", gameVersion: .game2)
		XCTAssert(App.current.recentlyViewedMissions[.game1]?.contents.count == 1,
			"Failed to set recently viewed missions")
		XCTAssert(App.current.recentlyViewedMissions[.game2]?.contents.count == 1,
			"Failed to set recently viewed missions")
	}
}
