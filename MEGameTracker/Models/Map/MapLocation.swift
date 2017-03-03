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

    static func sort(_ a: MapLocationable, b: MapLocationable) -> Bool {
        if a.mapLocationType != b.mapLocationType {
            return a.mapLocationType.intValue < b.mapLocationType.intValue
        } else if let aMission = a as? Mission, let bMission = b as? Mission {
            return Mission.sort(aMission, b: bMission)
        } else if let aMap = a as? Map, let bMap = b as? Map {
            return Map.sort(aMap, b: bMap)
        } else if let aItem = a as? Item, let bItem = b as? Item {
            return Item.sort(aItem, b: bItem)
        } else {
            return false
        }
    }
}
