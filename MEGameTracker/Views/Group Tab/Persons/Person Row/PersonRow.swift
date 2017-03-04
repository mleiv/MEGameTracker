//
//  PersonRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/6/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class PersonRow: UITableViewCell {
    
// MARK: Types
// MARK: Constants
    
// MARK: Outlets
    @IBOutlet fileprivate weak var photoImageView: UIImageView?
    
    @IBOutlet fileprivate weak var nameLabel: UILabel?
    @IBOutlet fileprivate weak var titleLabel: MarkupLabel?
    @IBOutlet fileprivate weak var statusLabel: MarkupLabel?
    @IBOutlet fileprivate weak var availabilityLabel: MarkupLabel?
    @IBOutlet fileprivate weak var heartButton: HeartButton?
    
    @IBOutlet fileprivate weak var disclosureImageView: UIImageView?
    
// MARK: Properties
    internal fileprivate(set) var person: Person?
    internal fileprivate(set) var isLoveInterest: Bool = false
    fileprivate var hideDisclosure: Bool = false
    fileprivate var onChangeLoveSetting: ((_ sender: HeartButton) -> Void)?
    
// MARK: Change Listeners And Change Status Flags
    fileprivate var isDefined = false
    
// MARK: Lifecycle Events
    public override func layoutSubviews() {
        if !isDefined {
            clearRow()
        }
        super.layoutSubviews()
    }
    
// MARK: Initialization
    public func define(
        person: Person?,
        isLoveInterest: Bool = false,
        hideDisclosure: Bool = false,
        onChangeLoveSetting: ((HeartButton) -> Void)? = nil
    ) {
        isDefined = true
        self.person = person
        self.isLoveInterest = isLoveInterest
        self.hideDisclosure = hideDisclosure
        self.onChangeLoveSetting = onChangeLoveSetting
        setup()
    }
    
// MARK: Populate Data
    fileprivate func setup() {
        guard photoImageView != nil else { return }
        
        nameLabel?.text = person?.name
        nameLabel?.isEnabled = person?.isAvailable ?? false
        
        Photo.addPhoto(from: person, toView: photoImageView, placeholder: UIImage.placeholderThumbnail())
        
        statusLabel?.isHidden = true // TODO
        
        if person?.isAvailable != true {
            availabilityLabel?.text = person?.getUnavailabilityMessages().joined(separator: ", ")
            availabilityLabel?.isHidden = availabilityLabel?.text?.isEmpty ?? true
            statusLabel?.isHidden = true
        } else {
//            statusLabel?.text = person?.status
            availabilityLabel?.isHidden = true
        }
        titleLabel?.text = person?.title
        heartButton?.isParamour = person?.isParamour ?? true
        heartButton?.isHidden = person?.isAvailableLoveInterest != true
        heartButton?.toggle(isOn: isLoveInterest)
        heartButton?.onClick = changeLoveSetting
        disclosureImageView?.isHidden = hideDisclosure
        selectionStyle = hideDisclosure ? .none : .default
        
        layoutIfNeeded()
    }
    
    /// Resets all text in the cases where row UI loads before data/setup.
    /// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
    fileprivate func clearRow() {
        photoImageView?.image = nil
        nameLabel?.text = " "
        titleLabel?.text = " "
        statusLabel?.text = " "
        availabilityLabel?.text = " "
        heartButton?.isOn = false
    }
    
// MARK: Supporting Functions
    fileprivate func changeLoveSetting(_ sender: AnyObject?) {
        isLoveInterest = heartButton?.isOn ?? false
        heartButton?.toggle(isOn: isLoveInterest)
        if let heartButton = heartButton {
            onChangeLoveSetting?(heartButton)
        }
    }
}
