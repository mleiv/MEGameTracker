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

    let isRun = true // this takes a long time, only run it when you want to
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        _ = DataDecision.deleteAll()
        _ = DataEvent.deleteAll()
        _ = DataItem.deleteAll()
        _ = DataMap.deleteAll()
        _ = DataMission.deleteAll()
        _ = DataPerson.deleteAll()
        super.tearDown()
    }
    
    /// Verify that all json import files are valid
    func testValidJson() {
        let files = BaseDataImport().progressFiles
        for row in files {
            var didParse = false
            let filename = row.filename
            do {
                if let file = Bundle.main.path(forResource: filename, ofType: "json") {
                    _ = try SerializableData(jsonString: try String(contentsOfFile: file))
                    didParse = true
                }
            } catch { 
                print("Failed to parse file \(filename): \(error)")
            }
            XCTAssert(didParse, "Failed to parse file")
        }
    }
    
    /// Clock the full import.
    func testBaseDataImportPerformance() {
        guard isRun else { return }
        let start = Date()
        BaseDataImport().run()
        let time = Int(Date().timeIntervalSince(start))
        print("Performance: testBaseDataImportTime ran in \(time) seconds")
        XCTAssert(time < 60)
        let mapsCount = DataMap.getCount()
        print(mapsCount)
        XCTAssert(mapsCount > 1500)
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
