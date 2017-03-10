//
//  Shepard.Gender.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/16/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {

	/// Game options for Shepard's gender.
	public enum Gender: String {
		case male = "M"
		case female = "F"

		/// Creates an enum from a string value, if possible.
		public init?(stringValue: String?) {
			self.init(rawValue: stringValue ?? "")
		}

		/// Returns the string value of an enum.
		public var stringValue: String {
			return rawValue
		}
	}
}

// already Equatable
