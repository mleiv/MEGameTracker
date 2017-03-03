//
//  ShepardLoveInterestView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class ShepardLoveInterestView: SimpleValueAltDataRow {
    
    public var controller: ShepardController? {
        didSet {
            reloadData()
        }
    }
    var loveInterest: Person?
    func getLoveInterest() -> Person? {
        if loveInterest?.id != controller?.shepard?.loveInterestId {
            var shepard = self.controller?.shepard
            loveInterest = shepard?.getLoveInterest()
        }
        return loveInterest
    }
    public var onClick: ((_ sender: UIView?) -> Void) = { _ in }
    
    override var heading: String? { return "Love Interest" }
    override var value: String? {
        if UIWindow.isInterfaceBuilder {
            return "Liara T'Soni"
        } else {
            return getLoveInterest()?.name ?? "(none)"
        }
    }
    override var originHint: String? { return controller?.originHint }
    override var viewController: UIViewController? { return controller }
    
    override func openRow(sender: UIView?) {
        onClick(sender)
    }
    
    var loveInterestNib: ShepardLoveInterestNib?
    
    override func setup() {
        isSettingUp = true
        if nib == nil, let view = ShepardLoveInterestNib.loadNib(heading: heading) {
            insertSubview(view, at: 0)
            view.fillView(self)
            nib = view
            loveInterestNib = view
            view.rowDivider?.isHidden = !showRowDivider
        }
        super.setup()
    }
    
    override func setupRow() {
        if let loveInterest = getLoveInterest() {
            Photo.addPhoto(from: loveInterest, toView: loveInterestNib?.loveInterestImageView, placeholder: UIImage.placeholderThumbnail())
        } else {
            loveInterestNib?.loveInterestImageView?.isHidden = true
        }
        super.setupRow()
    }
}


