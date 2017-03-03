//
//  MapLinkable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/26/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import Foundation

public protocol MapLinkable: class {

    var inMapId: String? { get set }
    var mapLocation: MapLocationable? { get }
    var isShowInParentMap: Bool { get }
    var originHint: String? { get }
}

