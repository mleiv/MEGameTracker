//
//  DependsOnDecisionValueType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/22/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public struct DependsOnDecisionValueType: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case value
    }

    public let id: String
    public let value: Bool

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        value = try container.decode(Bool.self, forKey: .value)
    }
}
