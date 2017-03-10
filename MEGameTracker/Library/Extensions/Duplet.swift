//
//  Duplet.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/4/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

/// http://stackoverflow.com/a/31169678
public struct Duplet<A: Hashable, B: Hashable>: Hashable {
	let one: A
	let two: B

	public var hashValue: Int {
		return one.hashValue ^ two.hashValue
	}

	public init(_ one: A, _ two: B) {
		self.one = one
		self.two = two
	}
}
public func ==<A, B> (lhs: Duplet<A, B>, rhs: Duplet<A, B>) -> Bool {
	return lhs.one == rhs.one && lhs.two == rhs.two
}
