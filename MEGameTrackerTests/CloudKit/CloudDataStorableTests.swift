//
//  CloudDataStorableTests.swift
//  MEGameTrackerTests
//
//  Created by Emily Ivie on 10/6/18.
//  Copyright © 2018 Emily Ivie. All rights reserved.
//

import XCTest
import CloudKit
@testable import MEGameTracker

class CloudDataStorableTests: XCTestCase {

    func testSerializeLastRecordData() {
        let zoneId = CKRecordZone.ID(zoneName: "zone", ownerName: "owner")
        let recordId = CKRecord.ID(recordName: "record", zoneID: zoneId)
        let record = CKRecord(recordType: "type", recordID: recordId)
        record["test1"] = "Hello"

        let serializedRecord = Decision.serializeLastRecordData(record: record)

        if let coder = try? NSKeyedUnarchiver(forReadingFrom: serializedRecord) {
            coder.requiresSecureCoding = true
            if let result = CKRecord(coder: coder) {
                XCTAssertEqual("zone", result.recordID.zoneID.zoneName)
                XCTAssertEqual("owner", result.recordID.zoneID.ownerName)
                XCTAssertEqual("record", result.recordID.recordName)
                XCTAssertEqual("type", result.recordType)
                // values are not passed with System Fields
                XCTAssertNil(result["test1"])
            } else {
                XCTAssertTrue(false, "Failed to decode record")
            }
        } else {
            XCTAssertTrue(false, "Failed to unarchive record data")
        }
    }

}
