//
//  MapLocationable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/26/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

/// Defines common characterstics to all objects available for display on a map.
public protocol MapLocationable {
// MARK: Required
	var id: String { get }
	var name: String { get }
	var description: String? { get }
	var annotationNote: String? { get }
	var gameVersion: GameVersion { get }

	var mapLocationType: MapLocationType { get }
	var mapLocationPoint: MapLocationPoint? { get set }
	var inMapId: String? { get set }
	var inMissionId: String? { get }
	var sortIndex: Int { get }

	var isHidden: Bool { get }
	var isAvailable: Bool { get }
	var unavailabilityMessages: [String] { get }

// MARK: Optional
	var searchableName: String { get }
	var linkToMapId: String? { get }
	var shownInMapId: String? { get set } // only set by view controllers
	var isShowInParentMap: Bool { get }
	var isShowInList: Bool { get }
	var isShowPin: Bool { get }
	var isOpensDetail: Bool { get }
}

extension MapLocationable {
	public var searchableName: String { return name }
	public var linkToMapId: String? { return nil }
	public var shownInMapId: String? { get { return nil } set {} }
	public var isShowInParentMap: Bool { return false }
	public var isShowInList: Bool { return true }
	public var isShowPin: Bool { return false }
	public var isOpensDetail: Bool { return false }

	public func isEqual(_ mapLocation: MapLocationable) -> Bool {
		return id == mapLocation.id
			&& gameVersion == mapLocation.gameVersion
			&& mapLocationType == mapLocation.mapLocationType
	}
}
