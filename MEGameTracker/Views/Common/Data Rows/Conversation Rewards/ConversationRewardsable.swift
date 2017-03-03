//
//  Decisionsable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/21/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol ConversationRewardsable: class {

    var mission: Mission? { get set }
    var originHint: String? { get }
}

