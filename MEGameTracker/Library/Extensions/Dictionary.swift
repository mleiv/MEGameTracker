//
//  Dictionary.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/11/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

extension Dictionary {
    // from: http://stackoverflow.com/a/24219069
    public init(_ pairs: [Element]) {
        self.init()
        for (k, v) in pairs {
            self[k] = v
        }
    }
    
    public func merge<T, U>(_ dictionary: [T: U]) -> [T: U] {
        var base: [T: U] = [:]
        for (key, value) in self {
            if let k = key as? T, let v = value as? U {
                base[k] = v
            }
        }
        for (key, value) in dictionary {
            base[key] = value
        }
        return base
    }
}
