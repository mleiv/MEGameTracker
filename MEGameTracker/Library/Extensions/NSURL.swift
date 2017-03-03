//
//  NSURL.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/15/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

//http://stackoverflow.com/a/26416178
extension URL {
    public var queryDictionary: [String: String] {
        var dictionary: [String: String] = [:]
        for item in URLComponents(url: self, resolvingAgainstBaseURL: true)?.queryItems ?? [] {
            dictionary[item.name] = item.value
        }
        // not perfect but okay for my purposes
        return dictionary
    }
}
