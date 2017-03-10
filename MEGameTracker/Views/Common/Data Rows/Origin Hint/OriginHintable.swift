//
//  OriginHintable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/26/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol OriginHintable: class {

	var originHint: String? { get }
	var originPrefix: String? { get }
}

extension OriginHintable {
	public var originPrefix: String? { return nil }
}
