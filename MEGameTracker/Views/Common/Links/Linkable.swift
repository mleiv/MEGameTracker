//
//  Linkable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/18/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

public protocol Linkable: class {
	var originController: UIViewController? { get }
	var linkOriginController: UIViewController? { get set }
	var sourceRect: CGRect { get } // for popover origin
}

extension Linkable where Self: UIView {
	public var originController: UIViewController? {
		return linkOriginController ?? UIApplication.topViewController
	}
	public var sourceRect: CGRect {
		return self.frame
	}
}
public protocol DeepLinkable {
	func deepLink(_ object: DeepLinkType?, type: String?)
}
public protocol DeepLinkType {}

extension Item: DeepLinkType {}

extension Map: DeepLinkType {}

extension Mission: DeepLinkType {}

extension Person: DeepLinkType {}
