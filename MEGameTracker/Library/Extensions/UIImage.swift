//
//  UIImage.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/3/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

extension UIImage {
	/// Interface Builder can't find image files when they are created via code.
	/// So, specify a class in the same package as the image file (here, AppDelegate), and IB will show the image.
	public static func ibSafeImage(named name: String) -> UIImage? {
		return UIImage(named: name, in: Bundle(for: AppDelegate.self), compatibleWith: nil)
	}

	public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
		let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
		UIGraphicsBeginImageContext(rect.size)
		let context = UIGraphicsGetCurrentContext()
		context?.setFillColor(color.cgColor)
		context?.fill(rect)
		let image = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		if let cgImage = image?.cgImage {
			self.init(cgImage: cgImage)
		} else {
			return nil
		}
	}
}
