//
//  MapRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final public class MapRow: UITableViewCell {

// MARK: Types
	typealias Checkbox = MapCheckbox

// MARK: Constants

// MARK: Outlets
	@IBOutlet private weak var widthStack: UIStackView?

	@IBOutlet private weak var checkboxStack: UIStackView?
	@IBOutlet private weak var checkboxImageView: UIImageView?
	@IBOutlet private weak var checkboxButton: UIButton?

	@IBOutlet private weak var parentMapLabel: MarkupLabel?
	@IBOutlet private weak var nameLabel: MarkupLabel?
	@IBOutlet private weak var descriptionLabel: MarkupLabel?
	@IBOutlet private weak var locationLabel: MarkupLabel?
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
			let breadcrumbs = (parentMap.getBreadcrumbs().map { $0.name } + [parentMap.name]).joined(separator: " > ")
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
		} else {
			if !isCalloutBoxRow,
				let text = map?.unavailabilityMessages.joined(separator: ", "), !text.isEmpty {
				availabilityLabel?.text = text
				availabilityLabel?.isHidden = false
			}
		}

		checkboxStack?.isHidden = !(map?.isExplorable ?? true)
		checkboxButton?.isHidden = checkboxStack?.isHidden ?? false
		setCheckboxImage(isExplored: map?.isExplored ?? false, isAvailable: map?.isAvailable ?? false)

		disclosureImageView?.isHidden = !allowsSegue || !(map?.isOpensDetail ?? true)
		disclosureImageWrapper?.isHidden = disclosureImageView?.isHidden ?? true

		layoutIfNeeded()

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
		if !isAvailable {
			checkboxImageView?.image = isExplored ? Checkbox.disabledFilled.getImage() : Checkbox.disabledEmpty.getImage()
		} else {
			checkboxImageView?.image = isExplored ? Checkbox.filled.getImage() : Checkbox.empty.getImage()
		}
	}

	private func toggleMap() {
		guard map?.isExplorable == true, let nameLabel = self.nameLabel else { return }
		let isExplored = !(self.map?.isExplored ?? false)
		let spinnerController = origin as? Spinnerable
		DispatchQueue.main.async {
			spinnerController?.startSpinner(inView: self.origin?.view)
			self.setCheckboxImage(isExplored: isExplored, isAvailable: self.map?.isAvailable ?? false)
			nameLabel.attributedText = Styles.current.applyStyle(
				nameLabel.identifier ?? "",
				toString: self.map?.name ?? ""
			).toggleStrikethrough(isExplored)
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
				_ = self.map?.changed(isExplored: isExplored, isSave: true)
				spinnerController?.stopSpinner(inView: self.origin?.view)
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
