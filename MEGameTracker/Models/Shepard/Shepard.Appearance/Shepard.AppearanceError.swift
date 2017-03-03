//
//  Shepard.AppearanceError.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

extension Shepard {
    public enum AppearanceError: String {
    
        case hairColorNotFound = "Hair color has no equivalent"
        case hairColorConverted = "Hair color was changed to an approximate equivalent"
        case eyeShadowColorNotFound = "Eyeshadow color has no equivalent"
        case eyeShadowColorConverted = "Eyeshadow color was changed to an approximate equivalent"
        case hairNotFound = "Hair style not found"
        case blushColorConverted = "Blush colors are too subtle to determine comparison between games"
        case scarMissing = "Scar has no equivalent in Game 2 or 3"
        
        /// Returns the string value of an enum.
        public var stringValue: String {
            return rawValue
        }
    }
}
