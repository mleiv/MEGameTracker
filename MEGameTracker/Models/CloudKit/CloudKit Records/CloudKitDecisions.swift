//
//  GameDecisions.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CloudKit

extension Decision: CloudDataStorable {

    /// (CloudDataStorable) Set any additional fields, specific to the object in question, for a cloud kit object.
    public func setAdditionalCloudFields(record: CKRecord) {
        record.setValue(isSelected as NSNumber, forKey: "isSelected")
    }
}

