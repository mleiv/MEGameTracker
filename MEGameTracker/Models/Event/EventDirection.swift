//
//  EventDirection.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/2/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// Specify the direction a current chain of changes is headed, so we don't duplicate up/down effects.
public enum EventDirection {
	case up, down, all, none
}
