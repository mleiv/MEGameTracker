//
//  PhotoEditable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 12/31/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

public protocol PhotoEditable: Photographical {
    mutating func savePhoto(image: UIImage) -> Bool // TODO: migrate to non-mutating
    func changed(
        photo: Photo,
        isSave: Bool
        ) -> Self
}

extension PhotoEditable {

    /// PhotoEditable Protocol
    /// A special setter for saving a UIImage
    public mutating func savePhoto(image: UIImage) -> Bool {
        return savePhoto(image: image, isSave: true)
    }
    /// A special setter for saving a UIImage
    public mutating func savePhoto(image: UIImage, isSave: Bool) -> Bool {
        if let photo = Photo.create(image, object: self) {
            self = changed(photo: photo, isSave: isSave)
            return true
        }
        return false
    }
}
