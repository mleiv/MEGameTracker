//
//  MapLocation.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/5/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

/// Not a real entity. This gathers up all common actions against MapLocationable objects.
public struct MapLocation {
	static let onChangeSelection = Signal<(MapLocationable)>()

	static func sort(_ first: MapLocationable, _ second: MapLocationable) -> Bool {
		if first.mapLocationType != second.mapLocationType {
			return first.mapLocationType.intValue < second.mapLocationType.intValue
		} else if let firstMission = first as? Mission, let secondMission = second as? Mission {
			return Mission.sort(firstMission, secondMission)
		} else if let firstMap = first as? Map, let secondMap = second as? Map {
			return Map.sort(firstMap, secondMap)
		} else if let firstItem = first as? Item, let secondItem = second as? Item {
			return Item.sort(firstItem, secondItem)
		} else {
			return false
		}
	}

    static func sortObjectives(_ first: MapLocationable, _ second: MapLocationable) -> Bool {
        if first.sortIndex != second.sortIndex {
            return first.sortIndex < second.sortIndex
        } else {
            return first.id < second.id
        }
    }
}
