//
//  GamePersons.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation
import CloudKit

extension Person: CloudDataStorable {

    /// (CloudDataStorable) Set any additional fields, specific to the object in question, for a cloud kit object.
    public func setAdditionalCloudFields(record: CKRecord) {
        record.setValue((photo?.stringValue ?? "") as NSString, forKey: "photo")
        if let photo = photo, photo.isCustomSavedPhoto {
            if let url = photo.getUrl() {
                record.setValue(CKAsset(fileURL: url), forKey: "photoFile")
            } else {
                record.setValue(nil, forKey: "photoFile")
            }
        }
    }
}

