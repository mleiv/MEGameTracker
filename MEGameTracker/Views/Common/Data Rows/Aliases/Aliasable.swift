//
//  Aliasable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol Aliasable: class {

	var aliases: [String] { get }
	var currentName: String? { get }
}
