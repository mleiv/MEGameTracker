//
//  Shepard.Name.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/16/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {

    /// 
    public enum Name {
    
        case defaultMaleName
        case defaultFemaleName
        case custom(name: String)
        
        public init?(name: String?, gender: Gender) {
            if name == Name.defaultMaleName.stringValue || (name == nil && gender == .male) {
                self = .defaultMaleName
            }
            if name == Name.defaultFemaleName.stringValue || (name == nil && gender == .female)  {
                self = .defaultFemaleName
            } else if let name = name {
                self = .custom(name: name)
            } else {
                return nil
            }
        }
        
        /// Returns the string value of an enum.
        public var stringValue: String? {
            let defaultMaleName = "John"
            let defaultFemaleName = "Jane"
            switch self {
            case .defaultMaleName:
                return defaultMaleName
            case .defaultFemaleName:
                return defaultFemaleName
            case .custom(let name):
                return name
            }
        }
    }
}

// MARK: Equatable
extension Shepard.Name: Equatable {}

public func ==(a: Shepard.Name, b: Shepard.Name) -> Bool {
    return a.stringValue == b.stringValue
}
