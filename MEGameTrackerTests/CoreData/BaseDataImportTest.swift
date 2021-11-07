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
        let files = BaseDataImport().progressFilesEvents + BaseDataImport().progressFilesOther
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
        let filename = "DataDecisions_2"
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
        XCTAssert(time < 300) // my ancient computer is slow
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

    // The downsides of manually editing JSON files instead of maintaining a relational database
    func testConversationIdsUnique() {
        let files = BaseDataImport().progressFilesOther
        var convoIds: [String: Bool] = [:]
        var noFailuresFound = true
        for row in files where row.type == .mission {
            let filename = row.filename
            if let file = Bundle.main.path(forResource: filename, ofType: "json"),
                let data = try? Data(contentsOf: URL(fileURLWithPath: file)),
                let extractedData = try? JSONSerialization.jsonObject(with: data, options: []),
                let missions = (extractedData as? [String: Any])?["missions"] as? [[String: Any]] {
                for mission in missions {
                    if let conversations = mission["conversationRewards"] as? [[String: Any]] {
                        for conversation in conversations {
                            for id in recursedConversationIds(conversation) {
                                if (convoIds[id] == true) {
                                    print("Duplicate conversation id: \(id)")
                                    noFailuresFound = false
                                } else {
                                    convoIds[id] = true
                                }
                            }
                        }
                    }
                }
            }
        }
        XCTAssert(noFailuresFound, "Found duplicate ids")
    }

    private func recursedConversationIds(_ data: [String: Any]) -> [String] {
        var ids: [String] = [];
        for (key, value) in data {
            if key == "id", let id = value as? String {
                ids.append( id)
                continue
            } else if let subDataList = value as? [[String: Any]] {
                for subData in subDataList {
                    ids.append(contentsOf: recursedConversationIds(subData))
                }
            } else if let subData = value as? [String: Any] {
                ids.append(contentsOf: recursedConversationIds(subData))
            }
        }
        return ids;
    }
}
