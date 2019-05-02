//
//  BaseDataImportTest.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/17/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import XCTest
import Nuke
@testable import MEGameTracker

final class BaseDataImportTest: MEGameTrackerTests {

    struct TestImport: CoreDataMigrationType {
        func run() {}
    }

    let isRun = true // this takes a long time, only run it when you want to

    override func setUp() {
        super.setUp()
        initializeSandboxedStore()
    }

    override func tearDown() {
        super.tearDown()
    }

    /// Verify that all json import files are valid
    func testValidJson() {
        let files = BaseDataImport().progressFiles
        for row in files {
            var didParse = false
            let filename = row.filename
//            print("\(filename)") // uncomment to debug
            do {
                if let file = Bundle.main.path(forResource: filename, ofType: "json") {
                    let data = try Data(contentsOf: URL(fileURLWithPath: file))
                    _ = try JSONSerialization.jsonObject(with: data, options: [])
                    _ = TestImport().importData(data, with: nil)
//                    print("\(ids)") // uncomment to debug
                    didParse = true
                }
            } catch {
                print("Failed to parse file \(filename): \(error)")
            }
            XCTAssert(didParse, "Failed to parse file \(filename)")
        }
    }

    func testOneImport() {
        let filename = "DataMaps_TerminusSystems"
        do {
            if let file = Bundle.main.path(forResource: filename, ofType: "json") {
                let data = try Data(contentsOf: URL(fileURLWithPath: file))
                let ids = TestImport().importData(data, with: nil)
                // print id in Codable init to find failure row
                print(ids)
            }
        } catch {
            // failure
            print("Failed to load file \(filename)")
        }
    }

    /// Clock the full import.
    func testBaseDataImportPerformance() {
        guard isRun else { return }
        let start = Date()
        BaseDataImport().run()
        let time = Int(Date().timeIntervalSince(start))
        print("Performance: testBaseDataImportTime ran in \(time) seconds")
        XCTAssert(time < 150) // my ancient computer is slow
        let decisionsCount = DataDecision.getCount()
        XCTAssert(decisionsCount > 100)
        let eventsCount = DataEvent.getCount()
        XCTAssert(eventsCount > 150)
        let itemsCount = DataItem.getCount()
        XCTAssert(itemsCount > 1100)
        let mapsCount = DataMap.getCount()
        XCTAssert(mapsCount > 1500)
        let missionsCount = DataMission.getCount()
        XCTAssert(missionsCount > 1500)
        let personsCount = DataPerson.getCount()
        XCTAssert(personsCount > 290)
    }

//    /// Clock the full import.
//    func testBaseDataImportPerformance() {
//        guard isRun else { return }

//        measureMetrics([XCTPerformanceMetric_WallClockTime], automaticallyStartMeasuring: false) {
//            let manager = self.getSandboxedManager()
//            self.startMeasuring()
//            BaseDataImport(manager: manager).run()
//            self.stopMeasuring()
////            let mapsCount = DataMap.getCount(with: manager)
////            XCTAssert(mapsCount > 1500, "Failed to import all maps")
//        }

//    }

}
