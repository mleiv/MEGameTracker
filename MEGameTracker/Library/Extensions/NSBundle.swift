//
//  NSBundle.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/11/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

extension Bundle {
	static var currentAppBundle: Bundle {
		return Bundle(for: ShepardFlowController.self)
	}
}
