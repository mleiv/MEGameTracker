//
//  Decisionsable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/22/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol SideEffectsable: class {

    var sideEffects: [String]? { get set }
    // handles onChange, select internally
}

