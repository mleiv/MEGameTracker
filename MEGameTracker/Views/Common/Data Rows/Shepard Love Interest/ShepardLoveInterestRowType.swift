//
//  ShepardLoveInterestRowType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/8/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

public struct ShepardLoveInterestRowType: ValueDataRowType {
	public typealias RowType = ShepardLoveInterestRow
	var view: RowType? { return row as? RowType }
    public var row: ValueDataRowDisplayable?

    public var identifier: String = "\(UUID().uuidString)"
    
    public var controller: ShepardController?
    public var onClick: ((UIButton)->Void) = { _ in }
	
    public var heading: String? { return "Love Interest" }
    public var value: String? { return loveInterest?.name ?? "(none)" }
	public var originHint: String? { return controller?.originHint }
	public var viewController: UIViewController? { return controller }
	
	private var loveInterest: Person?

    public init() {}
    public init(controller: ShepardController, view: ShepardLoveInterestRow?, onClick: @escaping ((UIButton) -> Void)) {
        self.controller = controller
        self.row = view as? ValueDataRowDisplayable
		self.onClick = onClick
    }
	
	public mutating func setupView() {
		loveInterest = getLoveInterest()
		setupView(type: RowType.self)
	}
	
    public mutating func setup(view: UIView?) {
		guard let view = view as? RowType else { return }
        if let loveInterest = loveInterest {
            Photo.addPhoto(from: loveInterest, toView: view.loveInterestImageView, placeholder: UIImage.placeholderThumbnail())
            view.loveInterestImageView?.isHidden = false
        } else {
            view.loveInterestImageView?.isHidden = true
        }
        view.valueLabel?.text = value
	}
	
    mutating func getLoveInterest() -> Person? {
		if UIWindow.isInterfaceBuilder {
			loveInterest = Person.getDummy()
		} else if loveInterest?.id != controller?.shepard?.loveInterestId {
            var shepard = self.controller?.shepard
            loveInterest = shepard?.getLoveInterest()
        }
        return loveInterest
    }
}
