//
//  GameMaps.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CloudKit

extension Map: CloudDataStorable {

    /// (CloudDataStorable)
    /// Set any additional fields, specific to the object in question, for a cloud kit object.
    public func setAdditionalCloudFields(record: CKRecord) {
        record.setValue(isExplored as NSNumber, forKey: "isExplored")
    }

    /// (CloudDataStorable Protocol)
    /// Alter any CK items before handing to codable to modify/create object
    public func getAdditionalCloudFields(changeRecord: CloudDataRecordChange) -> [String: Any?] {
        var changes = changeRecord.changeSet
        changes["isExplored"] = (changes["isExplored"] as? Int == 1) || (changes["isExplored"] as? Double == 1)
        changes.removeValue(forKey: "lastRecordData")
        return changes
    }
}
