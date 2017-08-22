//
//  CloudDataChangeValue.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/16/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

protocol CloudDataChangeValue {}

extension String: CloudDataChangeValue {}

//public struct CloudDataChangeValue {
//    enum CodingKeys: String, CodingKey {
//        case value
//    }
//    var value: Any?
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        value = try container.decodeIfPresent([String: Any?].self, forKey: .value) ?? [:]
//    }
//    public func decode() {
//    }
//    private func parseValue(value: Any?) {
//        if value is UUID
//            || value is Int
//            || value is Double
//            || value is Float
//            || value is Bool
//            || value is String
//            || value is Date {
//            self.value = value
//        } else {
//            self.value = nil
//        }
//    }
//}

