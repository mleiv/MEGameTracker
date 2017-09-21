//
//  JsonDecoder.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/14/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public struct SimpleCodable {
    public static var jsonDecoder: JSONDecoder = {
        let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.formatted(dateFormatter)
        return jsonDecoder
    }()
    public static var jsonEncoder: JSONEncoder = {
        let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let jsonEncoder = JSONEncoder()
        jsonEncoder.dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.formatted(dateFormatter)
        return jsonEncoder
    }()
}
