//
//  ItemDisplayType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/17/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

/// Distinguishes item variants so they can be displayed with UI differences. 
/// Consider this a subset of ItemType.
public enum ItemDisplayType {

	case goal
	case loot
	case medkit
	case novelty

	/// Returns a list of all possible enum variations.
	public static func list() -> [ItemDisplayType] {
		return [.goal, .loot, .medkit, .novelty]
	}

	/// Returns the string values of all the enum variations.
	fileprivate static let stringValues: [ItemDisplayType: String] = [
		.goal: "Goal",
		.loot: "Loot",
		.medkit: "MedKit",
		.novelty: "Novelty",
	]

	/// Creates an enum from a string value, if possible.
	public init?(stringValue: String?) {
		guard let type = ItemDisplayType.stringValues
			.filter({ $0.1 == stringValue })
			.flatMap({ $0.0 }).first
		else {
			return nil
		}
		self = type
	}

	/// Returns the string value of an enum.
	public var stringValue: String {
		return ItemDisplayType.stringValues[self] ?? "Unknown"
	}

	/// Returns a UI color appropriate to differentiate this item on a map.
	public var color: UIColor {
		switch self {
			case .goal: return UIColor(red: 0.8, green: 0.0, blue: 0.0, alpha: 1.0)
			case .loot: return UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)
			case .medkit: return UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
			case .novelty: return UIColor(red: 1.0, green: 0.6, blue: 0.7, alpha: 1.0)
		}
	}
}
