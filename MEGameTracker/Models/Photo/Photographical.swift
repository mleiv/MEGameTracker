//
//  Photographical.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/1/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import Foundation

/// Describes common properties and methods for managing photos. 
/// Allows for default values and custom uploads.
public protocol Photographical {
	var photoFileNameIdentifier: String { get }
	var photo: Photo? { get }
}
