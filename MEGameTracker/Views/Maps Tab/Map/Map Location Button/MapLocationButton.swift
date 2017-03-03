//
//  MapLocationButton.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 1/16/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

final public class MapLocationButton: UIButton {

    public var key: MapLocationPointKey?
    
    /// Overrides hit test to ignore rounded corners area
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let nib = superview as? MapLocationButtonNib else { return false }
        if nib.sizedMapLocationPoint?.radius != nil {
            let path = UIBezierPath(ovalIn: bounds)
            return super.point(inside: point, with: event) && path.contains(point)
        } else {
            return super.point(inside: point, with: event) 
        }
    }
}
