//
//  MapTests.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/23/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class MapTests: MEGameTrackerTests {

	// swiftlint:disable line_length

	let exodusJson = "{\"id\": \"G.Ear.Exodus\", \"name\": \"Exodus Cluster\", \"inMapId\": \"G.Base\", \"rerootBreadcrumbs\": true, \"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster1.pdf\",\"referenceSize\": \"2083x2083\", \"mapType\": \"Cluster\", \"mapLocationPoint\": {\"x\": 2417, \"y\": 3100, \"radius\": 30}, \"annotationNote\": \"Utopia, Asgard\", \"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Exodus_Cluster\"], \"gameVersionData\": {\"2\": {\"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster2.pdf\"}, \"3\": {\"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster3.pdf\"}},\"events\": [{\"type\": \"UnavailableInGame\", \"id\": \"Game2\"}]}"

	let utopiaJson = "{\"id\": \"G.Ear.Exo.Utopia\",\"name\": \"Utopia\",\"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster\\/Utopia1.pdf\",\"referenceSize\": \"2083x2083\",\"inMapId\": \"G.Ear.Exodus\", \"mapType\": \"System\",\"mapLocationPoint\": {\"x\": 304,\"y\": 1010,\"radius\": 133},\"annotationNote\": \"Arcadia, Eden Prime, Zion, Nirvana, Xanadu\",\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Utopia\"],\"gameVersionData\": {\"2\": {\"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster\\/Utopia2.pdf\"},\"3\": {\"image\": \"Galaxy_Map\\/Earth_Systems_Alliance\\/Exodus_Cluster\\/Utopia3.pdf\"}}}"

	let edenPrimeJson = "{\"id\": \"G.Ear.Exo.Uto.Eden\",\"name\": \"Eden Prime\",\"referenceSize\": \"2083x2083\",\"isSplitMenu\": true,\"image\": null,\"inMapId\": \"G.Ear.Exo.Utopia\", \"mapType\": \"Planet\",\"mapLocationPoint\": {\"x\": 1392,\"y\": 926,\"radius\": 37},\"relatedLinks\": [\"https:\\/\\/masseffect.wikia.com\\/wiki\\/Eden_Prime\"],\"gameVersionData\": {\"1\": {\"mapLocationPoint\": {\"x\": 721,\"y\": 842,\"radius\": 37},\"image\": \"Detail_Maps\\/Game1\\/Eden_Prime\\/Eden_Prime.pdf\"}},\"events\": [{\"type\": \"BlockedUntil\",\"id\": \"Unlocked Galaxy Map\",\"eraseParentValue\": true}]}"

	let edenPrimeGroundsJson = "{\"id\": \"G.Ear.Exo.Uto.Ede.A\",\"name\": \"Eden Prime Grounds\",\"isHidden\": true,\"referenceSize\": \"2083x2083\",\"image\": \"Detail_Maps\\/Game1\\/Eden_Prime\\/Eden_Prime_Grounds.pdf\",\"inMapId\": \"G.Ear.Exo.Uto.Eden\",\"mapType\":\"Area\",\"mapLocationPoint\": {\"x\": 150,\"y\": 650,\"width\": 1800,\"height\": 300},\"gameVersionData\": {\"1\": {\"isHidden\": false}},\"events\": [{\"type\": \"UnavailableInGame\",\"id\": \"Game3\"}]}"

	// swiftlint:enable line_length

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		super.tearDown()
	}

	func testEquality() {
		let map1 = create(Map.self, from: edenPrimeGroundsJson)
		let map2 = create(Map.self, from: edenPrimeGroundsJson)
		XCTAssert(map1 == map2, "Equality not working")
	}

	/// Test Map get methods.
	func testGetOne() {
		_ = create(Map.self, from: edenPrimeGroundsJson)
		let map = Map.get(id: "G.Ear.Exo.Uto.Ede.A")
		XCTAssert(map?.name == "Eden Prime Grounds", "Failed to load by id")
	}

	/// Test Map getAll methods.
	func testGetAll() {
		_ = create(Map.self, from: utopiaJson)
		_ = create(Map.self, from: edenPrimeJson)
		_ = create(Map.self, from: edenPrimeGroundsJson)
		let maps = Map.getAll()
		XCTAssert(maps.count == 3, "Failed to get all maps")
	}

	/// Test Map sort method.
	func testSort() {
		_ = create(Map.self, from: utopiaJson)
		_ = create(Map.self, from: edenPrimeGroundsJson)
		_ = create(Map.self, from: edenPrimeJson)
		// sorts by name
		let matches1 = Map.getAll().sorted(by: Map.sort)
        if matches1.count == 3 {
            XCTAssert(matches1[0].id == "G.Ear.Exo.Uto.Eden", "Failed to sort map 1 correctly")
            XCTAssert(matches1[1].id == "G.Ear.Exo.Uto.Ede.A", "Failed to sort map 2 correctly")
            XCTAssert(matches1[2].id == "G.Ear.Exo.Utopia", "Failed to sort map 3 correctly")
        }
	}

	/// Test Map game version variations.
	func testGetByGameVersion() {
		initializeCurrentGame() // needed for game version
		initializeGameVersionEvents()

		var exodus = create(Map.self, from: exodusJson)
		// Utopia is blocked in Game 2
		_ = exodus?.changed(gameVersion: .game2)
		XCTAssert(exodus?.isAvailable == false, "Failed to make map unavailable in game version")
        exodus = Map.get(id: "G.Ear.Exodus", gameVersion: .game2)
        XCTAssert(exodus?.isAvailable == false, "Failed to load map as unavailable in game version")
        let matches = Map.getAll(gameVersion: .game2)
        XCTAssert(matches.first?.isAvailable == false, "Failed to load map as unavailable in game version")
	}

	/// Test Map change action.
	func testChange() {
		initializeCurrentGame() // needed for saving with game uuid

		// - verify signal is fired
		let expectationMapAcquired = expectation(description: "Map on change triggered")
		Map.onChange.subscribe(on: self) { (changed: (id: String, object: Map?)) in
			if changed.id == "G.Ear.Exo.Utopia",
				let map = changed.object ?? Map.get(id: changed.id),
				map.isExplored {
				expectationMapAcquired.fulfill()
			}
		}

		let map = create(Map.self, from: utopiaJson)
		XCTAssert(map?.isExplored == false, "Reported incorrect initial map state")
		_ = map?.changed(isExplored: true, isSave: true)
		let map2 = Map.get(id: "G.Ear.Exo.Utopia")
		XCTAssert(map2?.isExplored == true, "Reported incorrect acquired map state")

		// - wait for signal
		waitForExpectations(timeout: 0.1) { _ in }
		Map.onChange.cancelSubscription(for: self)
	}

	/// Test Map breadcrumbs.
	func testBreadcrumbs() {
		_ = create(Map.self, from: exodusJson)
		_ = create(Map.self, from: utopiaJson)
		_ = create(Map.self, from: edenPrimeJson)
		let map = create(Map.self, from: edenPrimeGroundsJson)
		let breadcrumbs1 = map?.getBreadcrumbs().map({ $0.name }).joined(separator: ">")
		XCTAssert(breadcrumbs1 == "Exodus Cluster>Utopia>Eden Prime", "Reported incorrect breadcrumbs")
	}

    /// Test Map location point type.
    func testMapLocationPoint() {
        _ = create(Map.self, from: exodusJson)
        _ = create(Map.self, from: edenPrimeGroundsJson)
        // circle
        let map = Map.get(id: "G.Ear.Exodus")
        XCTAssert(map?.mapLocationPoint?.x == 2417, "Reported incorrect mapLocationPoint")
        // square
        let map2 = Map.get(id: "G.Ear.Exo.Uto.Ede.A")
        XCTAssert(map2?.mapLocationPoint?.width == 1800, "Reported incorrect mapLocationPoint")
    }
}
