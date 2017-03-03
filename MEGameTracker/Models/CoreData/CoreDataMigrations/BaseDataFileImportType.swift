//
//  BaseDataFileImportType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 2/13/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

public enum BaseDataFileImportType {
    case event, decision, person, map, item, mission
    
    public init?(jsonValue: String) {
        switch (jsonValue) {
            case "decisions": self = .decision
            case "events": self = .event
            case "items": self = .item
            case "maps": self = .map
            case "missions": self = .mission
            case "persons": self = .person
            default: return nil
        }
    }
    
    public static var list: [BaseDataFileImportType] {
        return [.decision, .event, .item, .map, .mission, .person]
    }
}
