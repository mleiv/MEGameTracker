//
//  MapLocationPoint.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/26/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

public typealias MapLocationPointKey = Duplet<CGFloat, CGFloat>

/// Defines a scalable location marker on a map, either square or circular.
public struct MapLocationPoint: Codable {

    enum CodingKeys: String, CodingKey {
        case x
        case y
        case radius
        case width
        case height
    }

// MARK: Properties
	public var x: CGFloat
	public var y: CGFloat
	public var radius: CGFloat?
	public var width: CGFloat
	public var height: CGFloat
	// x, y is altered for rectangles to locate center, so keep original values for encode:
    private var _x: CGFloat?
    private var _y: CGFloat?

// MARK: Computed Properties
	public var cgRect: CGRect { return CGRect(x: x, y: y, width: width, height: height) }
	public var cgPoint: CGPoint { return CGPoint(x: x, y: y) }
	public var key: MapLocationPointKey { return MapLocationPointKey(x, y) }

// MARK: Initialization
	public init(x: CGFloat, y: CGFloat, radius: CGFloat) {
		self.x = x
		self.y = y
		self.radius = radius
		self.width = radius * 2
		self.height = radius * 2
	}

	public init(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) {
		self.x = x
		self.y = y
		self.radius = nil
		self.width = width
		self.height = height
	}

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        if let radius = try container.decodeIfPresent(CGFloat.self, forKey: .radius) {
            self.init(x: x, y: y, radius: radius)
        } else {
            let width = try container.decode(CGFloat.self, forKey: .width)
            let height = try container.decode(CGFloat.self, forKey: .height)
            self.init(x: x + width/2, y: y + height/2, width: width, height: height)
            self._x = x
            self._y = y
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_x ?? x, forKey: .x)
        try container.encode(_y ?? y, forKey: .y)
        if let radius = self.radius {
            try container.encode(radius, forKey: .radius)
        } else {
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
        }
    }
}

// MARK: Basic Actions
extension MapLocationPoint {

	/// Converts a map location point from where it is on a base size map to where it is on an adjusted size map.
	public func fromSize(_ oldSize: CGSize, toSize newSize: CGSize) -> MapLocationPoint {
		let ratio = newSize.width / oldSize.width
		let x = self.x * ratio
		let y = self.y * ratio
		if let radius = radius {
			let r = radius * ratio
			return MapLocationPoint(x: x, y: y, radius: r)
		} else {
			let w = width * ratio
			let h = height * ratio
			return MapLocationPoint(x: x, y: y, width: w, height: h)
		}
	}

}

//// MARK: SerializedDataStorable
//extension MapLocationPoint: SerializedDataStorable {
//
//    public func getData() -> SerializableData {
//        var list: [String: SerializedDataStorable?] = [:]
//        if let radius = self.radius {
//            list["x"] = "\(x)"
//            list["y"] = "\(y)"
//            list["radius"] = "\(radius)"
//        } else {
//            // rect uses top left; convert from center
//            list["x"] = "\(x - (width / 2))"
//            list["y"] = "\(y - (height / 2))"
//            list["width"] = "\(width)"
//            list["height"] = "\(height)"
//        }
//        return SerializableData.safeInit(list)
//    }
//
//}
//
//// MARK: SerializedDataRetrievable
//extension MapLocationPoint: SerializedDataRetrievable {
//
//    public init?(data: SerializableData?) {
//        guard let data = data,
//              var x = data["x"]?.cgFloat,
//              var y = data["y"]?.cgFloat
//        else {
//            return nil
//        }
//
//        if let width = data["width"]?.cgFloat, let height = data["height"]?.cgFloat {
//            // rect uses top left; convert to center
//            x += (width / 2)
//            y += (height / 2)
//            self.init(x: x, y: y, width: width, height: height)
//        } else {
//            self.init(x: x, y: y, radius: data["radius"]?.cgFloat ?? 0)
//        }
//    }
//
//    public mutating func setData(_ data: SerializableData) {}
//}

// MARK: Equatable
extension MapLocationPoint: Equatable {
	public static func == (
		_ lhs: MapLocationPoint,
		_ rhs: MapLocationPoint
	) -> Bool {
		return lhs.x == rhs.x && lhs.y == rhs.y
	}
}
