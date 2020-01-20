//
//  MapRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class MapRow: UITableViewCell {
    let changeQueue = DispatchQueue(label: "MapRow.data", qos: .background)

// MARK: Types
	typealias Checkbox = MapCheckbox

// MARK: Constants

// MARK: Outlets
	@IBOutlet private weak var widthStack: UIStackView?

	@IBOutlet private weak var checkboxStack: UIStackView?
	@IBOutlet private weak var checkboxImageView: UIImageView?
	@IBOutlet private weak var checkboxButton: UIButton?

	@IBOutlet private weak var parentMapLabel: UILabel?
	@IBOutlet private weak var nameLabel: MarkupLabel?
	@IBOutlet private weak var descriptionLabel: UILabel?
	@IBOutlet private weak var locationLabel: UILabel?
	@IBOutlet private weak var availabilityLabel: MarkupLabel?

	@IBOutlet private weak var fillerView: UIView?
	@IBOutlet private weak var disclosureImageWrapper: UIView?
	@IBOutlet private weak var disclosureImageView: UIImageView?

	@IBAction private func onClickCheckbox(_ sender: UIButton) { toggleMap() }

// MARK: Properties
	private var map: Map?
	private weak var origin: UIViewController?
	private var isCalloutBoxRow: Bool = false
	private var allowsSegue: Bool = false
	private var isShowParentMapIfFound: Bool = false

// MARK: Change Listeners And Change Status Flags
	private var isDefined = false

// MARK: Lifecycle Events
	public override func layoutSubviews() {
		if !isDefined {
			clearRow()
		}
		super.layoutSubviews()
	}

// MARK: Initialization
	/// Sets up the row - expects to be in main/UI dispatch queue. 
	/// Also, table layout needs to wait for this, 
	///    so don't run it asynchronously or the layout will be wrong.
	public func define(
		map: Map?,
		origin: UIViewController?,
		isCalloutBoxRow: Bool = false,
		allowsSegue: Bool = true,
		isShowParentMapIfFound: Bool = false
	) -> Bool {
		isDefined = true
		self.map = map
		self.origin = origin
		self.isCalloutBoxRow = isCalloutBoxRow
		self.allowsSegue = allowsSegue
		self.isShowParentMapIfFound = isShowParentMapIfFound

		return setup()
	}

// MARK: Populate Data
	private func setup() -> Bool {
		guard !UIWindow.isInterfaceBuilder && nameLabel != nil else { return false }

		parentMapLabel?.isHidden = true
		if isShowParentMapIfFound,
			let mapId = map?.inMapId,
			mapId != "G.Base",
			let parentMap = Map.get(id: mapId) {
			// usually we don't want location data on items:
			let breadcrumbs = (
                    parentMap.getBreadcrumbs()
                    .map { $0.name }
                    + [parentMap.name]
                ).joined(separator: " > ")
			parentMapLabel?.text = breadcrumbs
			parentMapLabel?.isHidden = false
		}

		nameLabel?.text = map?.name // MarkupLabel relies on this to setup, so use .text first
		nameLabel?.attributedText = nameLabel?.attributedText?.toggleStrikethrough(map?.isExplored ?? false)
//		nameLabel?.isEnabled = map?.isAvailable ?? false
		nameLabel?.alpha = map?.isAvailable ?? false ? 1.0 : 0.5

		descriptionLabel?.isHidden = true
		locationLabel?.isHidden = true
		availabilityLabel?.isHidden = true

		if map?.isAvailable ?? false {
			if let annotationNote = map?.annotationNote, !annotationNote.isEmpty {
				descriptionLabel?.text = " - " + annotationNote // faux margin left
				descriptionLabel?.isHidden = false
			}
            disclosureImageView?.tintColor = MEGameTrackerColor.renegade
		} else {
			if !isCalloutBoxRow,
				let text = map?.unavailabilityMessages.joined(separator: ", "), !text.isEmpty {
				availabilityLabel?.text = text
				availabilityLabel?.isHidden = false
			}
            disclosureImageView?.tintColor = MEGameTrackerColor.disabled
		}

        let hideCheckbox = !(map?.isExplorable ?? true)
		checkboxStack?.isHidden = hideCheckbox
		checkboxButton?.isHidden = hideCheckbox
        backgroundColor = isCalloutBoxRow ? UIColor.clear : UIColor(named: "background")!
		setCheckboxImage(isExplored: map?.isExplored ?? false, isAvailable: map?.isAvailable ?? false)

		disclosureImageView?.isHidden = !allowsSegue || !(map?.isOpensDetail ?? true)
		disclosureImageWrapper?.isHidden = disclosureImageView?.isHidden ?? true

		return true
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	private func clearRow() {
		parentMapLabel?.text = ""
		nameLabel?.text = ""
		descriptionLabel?.text = ""
		locationLabel?.text = ""
		availabilityLabel?.text = ""
	}

// MARK: Supporting Functions
	private func setCheckboxImage(isExplored: Bool, isAvailable: Bool) {
        checkboxImageView?.image = isExplored ? Checkbox.filled.getImage() : Checkbox.empty.getImage()
		if !isAvailable {
            checkboxImageView?.tintColor = MEGameTrackerColor.disabled
		} else {
            checkboxImageView?.tintColor = MEGameTrackerColor.renegade
		}
	}

	private func toggleMap() {
		guard let map = map, map.isExplorable == true else { return }
		let isExplored = !map.isExplored
		let spinnerController = origin as? Spinnerable
		DispatchQueue.main.async {
			spinnerController?.startSpinner(inView: self.origin?.view)
            // make UI changes now
            self.nameLabel?.attributedText = self.nameLabel?.attributedText?.toggleStrikethrough(isExplored)
			self.setCheckboxImage(isExplored: isExplored, isAvailable: map.isAvailable)
            self.changeQueue.sync {
                // save changes to DB
                self.map = map.changed(isExplored: isExplored, isSave: true)
                DispatchQueue.main.async {
                    spinnerController?.stopSpinner(inView: self.origin?.view)
                }
			}
		}
	}
}

// MARK: CalloutCellType
extension MapRow: CalloutCellType {
	public var estimatedWidth: CGFloat {
        layoutIfNeeded()
		let rightPad: CGFloat = (disclosureImageView?.isHidden ?? true) ? 5 : 0
		let fillerWidth: CGFloat = fillerView?.bounds.width ?? 0
		return bounds.width + (rightPad - fillerWidth)
	}
}

// MARK: Supporting Types
public enum MapCheckbox {
	case empty, filled, disabledEmpty, disabledFilled
	public func getImage() -> UIImage? {
		guard !UIWindow.isInterfaceBuilder else {
			return UIImage(named: "Map Checkbox Filled", in: Bundle(for: App.self), compatibleWith: nil)
		}
		switch self {
		case .empty:
			return App.current.recentlyViewedImages.get("Map Checkbox Empty")
		case .filled:
			return App.current.recentlyViewedImages.get("Map Checkbox Filled")
		case .disabledEmpty:
			return App.current.recentlyViewedImages.get("Map Checkbox Empty (Disabled)")
		case .disabledFilled:
			return App.current.recentlyViewedImages.get("Map Checkbox Filled (Disabled)")
		}
	}
}
