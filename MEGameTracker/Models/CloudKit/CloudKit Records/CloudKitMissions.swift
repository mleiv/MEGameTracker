//
//  GameMissions.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CloudKit

extension Mission: CloudDataStorable {

    /// (CloudDataStorable)
    /// Set any additional fields, specific to the object in question, for a cloud kit object.
    public func setAdditionalCloudFields(record: CKRecord) {
        record.setValue(isCompleted as NSNumber, forKey: "isCompleted")
        record.setValue(name as NSString, forKey: "name")
        record.setValue(selectedConversationRewards, forKey: "selectedConversationRewards")
    }

    /// (CloudDataStorable Protocol)
    /// Alter any CK items before handing to codable to modify/create object
    public func getAdditionalCloudFields(changeRecord: CloudDataRecordChange) -> [String: Any?] {
        var changes = changeRecord.changeSet
        changes["isCompleted"] = (changes["isCompleted"] as? Int == 1) || (changes["isCompleted"] as? Double == 1)
        changes.removeValue(forKey: "lastRecordData")
        return changes
    }
}
