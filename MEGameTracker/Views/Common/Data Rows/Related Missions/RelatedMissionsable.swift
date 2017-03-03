//
//  RelatedMissionsable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/22/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol RelatedMissionsable: class {

    var relatedMissions: [Mission] { get set }
    // handles onChange, select internally
}

