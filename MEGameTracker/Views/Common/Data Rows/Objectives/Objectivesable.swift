//
//  Objectivesable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/22/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol Objectivesable: class {

    var objectives: [MapLocationable] { get set }
    var originHint: String? { get }
    
    // handles onChange, select internally
}


