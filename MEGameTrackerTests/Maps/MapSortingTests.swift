//
//  MapLocationsSortingTests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 5/15/2016.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import XCTest
@testable import MEGameTracker

final class MapSortingTests: MEGameTrackerTests {

	var maps: [Map] = []

	override func setUp() {
		super.setUp()
	}

	override func tearDown() {
		_ = Map.deleteAll()
		super.tearDown()
	}

	func testNoParentMapSort() {
		// swiftlint:disable line_length
		guard let dataMap1 = create(DataMap.self, from: "{\"id\":\"G.7.1\",\"inMapId\":\"G.7\",\"gameVersion\":\"1\",\"name\":\"Some Map\"}"),
			let dataMap2 = create(DataMap.self, from: "{\"id\":\"G.5.2\",\"inMapId\":\"G.5\",\"gameVersion\":\"1\",\"name\":\"Some Child Map\"}"),
			let dataMap3 = create(DataMap.self, from: "{\"id\":\"G.9\",\"gameVersion\":\"1\",\"name\":\"Some Child Map\"}")
		else {
			XCTAssert(false, "Could not initialize DataMap base")
			return
		}
		// swiftlint:enable line_length

        let map1 = Map(id: dataMap1.id, generalData: dataMap1)
        let map2 = Map(id: dataMap2.id, generalData: dataMap2)
        let map3 = Map(id: dataMap3.id, generalData: dataMap3)
		let maps: [Map] = [map1, map2, map3].sorted(by: Map.sort)
		XCTAssert(maps[0] == map3, "Invalid sort index 1")
		XCTAssert(maps[1] == map2, "Invalid sort index 2")
		XCTAssert(maps[2] == map1, "Invalid sort index 3")
	}

}
