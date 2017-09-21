//
//  CloudDataRecordChange.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/15/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public struct CloudDataRecordChange {
    public let recordId: String
    public let isDeleted: Bool?
    public var changeSet: [String: Any?] = [:]
    public var lastRecordData = Data()
}
