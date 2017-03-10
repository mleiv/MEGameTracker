//
//  LineCenteredTextImage.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/17/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

class LineCenteredTextImage: NSTextAttachment {
	let baselineUpRatio = CGFloat(0.5)

	override func attachmentBounds(
		for textContainer: NSTextContainer?,
		proposedLineFragment lineFrag: CGRect,
		glyphPosition position: CGPoint,
		characterIndex charIndex: Int
	) -> CGRect {
		if let size = self.image?.size {
			var bounds = CGRect.zero
			bounds.size = size
			// negative numbers push down, positive up
			let offsetY = ((lineFrag.size.height * baselineUpRatio) - size.height) / 2.0
			bounds.origin = CGPoint(x: 0, y: offsetY)
			return bounds
		}
		return bounds
	}
}
