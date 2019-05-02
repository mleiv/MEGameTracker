//
//  MapSize.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/26/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

public struct MapSize: Codable {

    let size: CGSize?

    public init() { size = nil }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let referenceSizeBits = (try? container.decode(String.self))?.components(separatedBy: "x"),
            referenceSizeBits.count == 2,
            let w = NumberFormatter().number(from: referenceSizeBits[0]),
            let h = NumberFormatter().number(from: referenceSizeBits[1]) {
            size = CGSize(width: Double(truncating: w), height: Double(truncating: h))
        } else {
            size = nil
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let w = size?.width, let h = size?.height {
            var container = encoder.singleValueContainer()
            try container.encode("\(w)x\(h)")
        }
    }
}
