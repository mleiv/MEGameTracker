//
//  RecentlyViewedImages.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 7/4/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

/// Keeps a local cache of recently accessed images.
public struct RecentlyViewedImages {

// MARK: Properties

    public var contents: [String: UIImage?] = [:]
    public var contentsByLastUsed: [String] = []
    public let maxElements: Int
    
// MARK: Initialization

    public init(maxElements: Int = -1) {
        self.maxElements = maxElements
        self.contents = [:]
        self.contentsByLastUsed = []
    }
}

// MARK: Basic Actions
extension RecentlyViewedImages {
    
    /// Lookup an image in the cache and add it if it's missing. Return the result either way.
    public mutating func get(_ name: String) -> UIImage? {
        if contents[name] == nil {
            let image = UIImage(named: name, in: Bundle(for: App.self), compatibleWith: nil)
            contents[name] = image
        }
        let image = contents[name] ?? nil
        contentsByLastUsed.append(name)
        if contentsByLastUsed.count > maxElements {
            contentsByLastUsed = Array(contentsByLastUsed.prefix(maxElements))
        }
        contents = Dictionary(contentsByLastUsed.map { ($0, contents[$0] ?? nil) })
        return image
    }
    
    //TODO: Add url version of get, change max to be size-based?
}
