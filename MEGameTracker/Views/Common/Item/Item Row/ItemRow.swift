//
//  ItemRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/2/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class ItemRow: UITableViewCell {
    
// MARK: Types
    typealias Checkbox = ItemCheckbox

// MARK: Constants
    fileprivate let priceMessage = "Price: %@"
    
// MARK: Outlets
    @IBOutlet fileprivate weak var widthStack: UIStackView?
    
    @IBOutlet fileprivate weak var checkboxImageView: UIImageView?
    
    @IBOutlet fileprivate weak var parentMissionLabel: MarkupLabel?
    @IBOutlet fileprivate weak var nameLabel: IBStyledLabel?
    @IBOutlet fileprivate weak var descriptionLabel: UILabel?
    @IBOutlet fileprivate weak var locationLabel: UILabel?
    @IBOutlet fileprivate weak var costLabel: UILabel?
    @IBOutlet fileprivate weak var availabilityLabel: UILabel?
    
    @IBOutlet fileprivate weak var fillerView: UIView?
    @IBOutlet fileprivate weak var disclosureImageWrapper: UIView?
    @IBOutlet fileprivate weak var disclosureImageView: UIImageView?
    
    @IBAction fileprivate func onClickCheckbox(_ sender: UIButton) { toggleItem() }
    
// MARK: Properties
    internal fileprivate(set) var item: Item?
    fileprivate weak var origin: UIViewController?
    fileprivate var isCalloutBoxRow: Bool = false
    fileprivate var allowsSegue: Bool = false
    fileprivate var isShowParentMissionIfFound = false
    
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
        item: Item?,
        origin: UIViewController?,
        isCalloutBoxRow: Bool = false,
        allowsSegue: Bool = true,
        isShowParentMissionIfFound: Bool = false
    ) -> Bool {
        isDefined = true
        self.item = item
        self.origin = origin
        self.isCalloutBoxRow = isCalloutBoxRow
        self.allowsSegue = allowsSegue
        self.isShowParentMissionIfFound = isShowParentMissionIfFound
        return setup()
    }

// MARK: Populate Data
    fileprivate func setup() -> Bool {
        guard let nameLabel = self.nameLabel else { return false }
        
        parentMissionLabel?.isHidden = true
        if isShowParentMissionIfFound,
            let missionId = item?.inMissionId,
            let parentMission = Mission.get(id: missionId) {
            parentMissionLabel?.text = parentMission.name
            parentMissionLabel?.isHidden = parentMission.name.isEmpty
        }
        
        nameLabel.text = item?.name // MarkupLabel relies on this to setup, so use .text first
        nameLabel.attributedText = nameLabel.attributedText?.toggleStrikethrough(item?.isAcquired ?? false)
//        nameLabel.isEnabled = item?.isAvailable ?? false
        nameLabel.alpha = item?.isAvailable ?? false ? 1.0 : 0.5
        
        descriptionLabel?.isHidden = true
        locationLabel?.isHidden = true
        availabilityLabel?.isHidden = true
        costLabel?.isHidden = true
        
        disclosureImageView?.isHidden = true
        
        if !(item?.isAvailable ?? false) {
            if !isCalloutBoxRow, let text = item?.unavailabilityMessages.joined(separator: ", ") , !text.isEmpty {
                availabilityLabel?.text = text
                availabilityLabel?.isHidden = false
            }
        } else {
            if let annotationNote = item?.annotationNote , !annotationNote.isEmpty {
                descriptionLabel?.text = annotationNote
                descriptionLabel?.isHidden = false
            } else if !isCalloutBoxRow {
                if let mapId = item?.inMapId, let map = Map.get(id: mapId) {
                    // usually we don't want location data on items:
                    let breadcrumbs = (map.getBreadcrumbs().map{ $0.name } + [map.name]).joined(separator: " > ")
                    locationLabel?.text = breadcrumbs
                    locationLabel?.isHidden = false
                }
            }
            if let price = item?.price , !price.isEmpty {
                costLabel?.text = String(format: priceMessage, price)
                costLabel?.isHidden = costLabel?.text?.isEmpty ?? true
            }
            // TODO: make item popover with more information
            let hasLinkToMap = !isCalloutBoxRow && item?.inMapId != nil
            disclosureImageView?.isHidden = (item?.hasNoAdditionalData ?? true) && !hasLinkToMap
        }
        setCheckboxImage(isAcquired: item?.isAcquired ?? false, isAvailable: item?.isAvailable ?? false)

        // TODO: make item view page
        
        layoutIfNeeded()
        
        return true
    }
    
    /// Resets all text in the cases where row UI loads before data/setup.
    /// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
    fileprivate func clearRow() {
        parentMissionLabel?.text = ""
        nameLabel?.text = ""
        descriptionLabel?.text = ""
        locationLabel?.text = ""
        costLabel?.text = ""
        availabilityLabel?.text = ""
    }
    
// MARK: Supporting Functions
    fileprivate func setCheckboxImage(isAcquired: Bool, isAvailable: Bool) {
        if !isAvailable {
            checkboxImageView?.image = isAcquired ? Checkbox.disabledFilled.getImage() : Checkbox.disabledEmpty.getImage()
        } else {
            checkboxImageView?.image = isAcquired ? Checkbox.filled.getImage() : Checkbox.empty.getImage()
        }
    }
    
    fileprivate func toggleItem() {
        guard let nameLabel = self.nameLabel else { return }
        let isAcquired = !(self.item?.isAcquired ?? false)
        let spinnerController = origin as? Spinnerable
        DispatchQueue.main.async {
            spinnerController?.startSpinner(inView: self.origin?.view)
            self.setCheckboxImage(isAcquired: isAcquired, isAvailable: self.item?.isAvailable ?? false)
            nameLabel.attributedText = Styles.applyStyle(nameLabel.identifier ?? "", toString: self.item?.name ?? "").toggleStrikethrough(isAcquired)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
                self.item?.change(isAcquired: isAcquired, isSave: true)
                spinnerController?.stopSpinner(inView: self.origin?.view)
            }
        }
    }
}

// MARK: CalloutCellType
extension ItemRow: CalloutCellType {
    public var estimatedWidth: CGFloat {
        layoutIfNeeded()
        let rightPad: CGFloat = (disclosureImageView?.isHidden ?? true) ? 5 : 0
        let fillerWidth: CGFloat = fillerView?.bounds.width ?? 0
        return bounds.width + (rightPad - fillerWidth)
    }
}

// MARK: Supporting Types
public enum ItemCheckbox {
    case empty, filled, disabledEmpty, disabledFilled
    public func getImage() -> UIImage? {
        guard !UIWindow.isInterfaceBuilder else {
            return UIImage(named: "Item Checkbox Filled", in: Bundle(for: App.self), compatibleWith: nil)
        }
        switch self {
        case .empty:
            return App.current.recentlyViewedImages.get("Item Checkbox Empty")
        case .filled:
            return App.current.recentlyViewedImages.get("Item Checkbox Filled")
        case .disabledEmpty:
            return App.current.recentlyViewedImages.get("Item Checkbox Empty (Disabled)")
        case .disabledFilled:
            return App.current.recentlyViewedImages.get("Item Checkbox Filled (Disabled)")
        }
    }
}
