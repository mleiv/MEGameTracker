//
//  UIImage+Placeholder.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/7/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

extension UIImage {
	public static func placeholder() -> UIImage? {
		 return UIImage(named: "Placeholder", in: Bundle.currentAppBundle, compatibleWith: nil)
	}
	public static func placeholderThumbnail() -> UIImage? {
		 return UIImage(named: "Placeholder Thumbnail", in: Bundle.currentAppBundle, compatibleWith: nil)
	}
}
