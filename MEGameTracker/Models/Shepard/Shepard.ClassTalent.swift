//
//  Shepard.ClassTalent.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/15/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {

	// Dumb reserved words, uhg.

	/// Game options for Shepard's class.
	public enum ClassTalent: String {
		case soldier = "Soldier"
		case engineer = "Engineer"
		case adept = "Adept"
		case infiltrator = "Infiltrator"
		case sentinel = "Sentinel"
		case vanguard = "Vanguard"

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
