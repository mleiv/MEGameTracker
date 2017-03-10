//
//  AbbreviatedMapData.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public struct AbbreviatedMapData {
	public let id: String
	public let name: String

	public init(id: String, name: String) {
		self.id = id
		self.name = name
	}

	// provides a deepLinkable string for the specified data
	public func deepLinkString(
		mapLocationId: String? = nil,
		showLinkIcon: Bool = false,
		alwaysDeepLink: Bool = false
	) -> String {
		var extraParams = showLinkIcon ? "" : "&hideicon=1"
		extraParams += alwaysDeepLink ? "&alwaysdeeplink=1" : ""
		if let mapId = mapLocationId {
			return "[\(name)|megametracker://maplocation?id=\(mapId)\(extraParams)&type=Map]"
		} else {
			return "[\(name)|megametracker://map?id=\(id)\(extraParams)]"
		}
	}
}
