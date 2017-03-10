//
//  Comparison.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/16/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
	return l < r
  case (nil, _?):
	return true
  default:
	return false
  }
}
public func > <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
	return l > r
  default:
	return rhs < lhs
  }
}
public func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
	return l >= r
  default:
	return !(lhs < rhs)
  }
}
public func <= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
	return l <= r
  default:
	return !(lhs > rhs)
  }
}
