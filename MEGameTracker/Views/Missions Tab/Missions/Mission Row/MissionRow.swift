//
//  MissionRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/22/15.
//  Copyright © 2015 urdnot. All rights reserved.
//

import UIKit

final class MissionRow: UITableViewCell {

// MARK: Types
	typealias Checkbox = MissionCheckbox

// MARK: Constants
	fileprivate let pendingMissionsMessage = "(%@/%@)"

// MARK: Outlets
	@IBOutlet fileprivate weak var widthStack: UIStackView?

	@IBOutlet fileprivate weak var checkboxImageView: UIImageView?

	@IBOutlet fileprivate weak var parentMissionLabel: MarkupLabel?
	@IBOutlet fileprivate weak var nameLabel: MarkupLabel?
	@IBOutlet fileprivate weak var descriptionLabel: MarkupLabel?
	@IBOutlet fileprivate weak var locationLabel: MarkupLabel?
	@IBOutlet fileprivate weak var availabilityLabel: MarkupLabel?

	@IBOutlet fileprivate weak var fillerView: UIView?
	@IBOutlet fileprivate weak var disclosureImageWrapper: UIView?
	@IBOutlet fileprivate weak var disclosureImageView: UIImageView?

	@IBAction fileprivate func onClickCheckbox(_ sender: UIButton) { toggleMission() }

// MARK: Properties
	internal fileprivate(set) var mission: Mission?
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
	/// Sets up the row - expects to be in main/UI dispatch queue. 
	/// Also, table layout needs to wait for this, 
	///    so don't run it asynchronously or the layout will be wrong.
	public func define(
		mission: Mission?,
		origin: UIViewController?,
		isCalloutBoxRow: Bool = false,
		allowsSegue: Bool = true,
		isShowParentMissionIfFound: Bool = false
	) -> Bool {
		isDefined = true
		self.mission = mission
		self.origin = origin
		self.isCalloutBoxRow = isCalloutBoxRow
		self.allowsSegue = allowsSegue
		self.isShowParentMissionIfFound = isShowParentMissionIfFound

		return self.setup()
	}

// MARK: Populate Data
	fileprivate func setup() -> Bool {
		guard !UIWindow.isInterfaceBuilder && nameLabel != nil else { return false }

		parentMissionLabel?.isHidden = true
		var referenceMission = mission
		while isShowParentMissionIfFound && referenceMission?.missionType == .objective,
			  let parentMission = referenceMission?.parentMission {
			parentMissionLabel?.text = parentMission.name
			parentMissionLabel?.isHidden = parentMission.name.isEmpty
			referenceMission = parentMission
		}

		nameLabel?.text = mission?.name // MarkupLabel relies on this to setup, so use .text first
		nameLabel?.attributedText = nameLabel?.attributedText?.toggleStrikethrough(mission?.isCompleted ?? false)
//		nameLabel?.isEnabled = mission?.isAvailable ?? false
		nameLabel?.alpha = mission?.isAvailable ?? false ? 1.0 : 0.5

		descriptionLabel?.isHidden = true
		locationLabel?.isHidden = true
		availabilityLabel?.isHidden = true

		if mission?.isAvailable == true {
			if let annotationNote = mission?.annotationNote,
				!annotationNote.isEmpty {
				descriptionLabel?.text = annotationNote
				descriptionLabel?.isHidden = false
			} else if !isCalloutBoxRow {
				if let mapId = mission?.inMapId, let map = Map.get(id: mapId) {
					// usually we don't want location data on items:
					let breadcrumbs = (map.getBreadcrumbs().map { $0.name } + [map.name]).joined(separator: " > ")
					locationLabel?.text = breadcrumbs
					locationLabel?.isHidden = false
				}
			}
		} else {
			if !isCalloutBoxRow,
				let text = mission?.unavailabilityMessages.joined(separator: ", "),
				!text.isEmpty {
				availabilityLabel?.text = text
				availabilityLabel?.isHidden = false
			}
		}
		setCheckboxImage(isCompleted: mission?.isCompleted ?? false, isAvailable: mission?.isAvailable ?? false)

		disclosureImageView?.isHidden = !allowsSegue
		disclosureImageWrapper?.isHidden = disclosureImageView?.isHidden ?? true

		layoutIfNeeded()

		return true
	}

	/// Resets all text in the cases where row UI loads before data/setup.
	/// (I prefer to use sample UI data in nib, so I need it to disappear before UI displays.)
	fileprivate func clearRow() {
		parentMissionLabel?.text = ""
		nameLabel?.text = "Loading ..."
		descriptionLabel?.text = ""
		locationLabel?.text = ""
		availabilityLabel?.text = ""
	}

// MARK: Supporting Functions
	fileprivate func setCheckboxImage(isCompleted: Bool, isAvailable: Bool) {
		// TODO: make into protocol
		if !isAvailable {
			checkboxImageView?.image = isCompleted ? Checkbox.disabledFilled.getImage() : Checkbox.disabledEmpty.getImage()
		} else {
			checkboxImageView?.image = isCompleted ? Checkbox.filled.getImage() : Checkbox.empty.getImage()
		}
	}

	fileprivate func toggleMission() {
		guard let nameLabel = self.nameLabel else { return }
		let isCompleted = !(self.mission?.isCompleted ?? false)
		let spinnerController = origin as? Spinnerable
		DispatchQueue.main.async {
			spinnerController?.startSpinner(inView: self.origin?.view)
			self.setCheckboxImage(isCompleted: isCompleted, isAvailable: self.mission?.isAvailable ?? false)
			nameLabel.attributedText = Styles.current.applyStyle(nameLabel.identifier
				?? "", toString: self.mission?.name ?? "").toggleStrikethrough(isCompleted)
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(1)) {
				self.mission?.change(isCompleted: isCompleted, isSave: true)
				spinnerController?.stopSpinner(inView: self.origin?.view)
			}
		}
	}

}

// MARK: CalloutCellType
extension MissionRow: CalloutCellType {
	public var estimatedWidth: CGFloat {
		layoutIfNeeded()
		let rightPad: CGFloat = (disclosureImageView?.isHidden ?? true) ? 5 : 0
		let fillerWidth: CGFloat = fillerView?.bounds.width ?? 0
		return bounds.width + (rightPad - fillerWidth)
	}
}

// MARK: Supporting Types
public enum MissionCheckbox {
	// TODO: Unify checkboxes into a struct Checkbox.mission.empty
	case empty, filled, disabledEmpty, disabledFilled
	public func getImage() -> UIImage? {
		guard !UIWindow.isInterfaceBuilder else {
			return UIImage(named: "Mission Checkbox Filled", in: Bundle(for: App.self), compatibleWith: nil)
		}
		switch self {
		case .empty:
			return App.current.recentlyViewedImages.get("Mission Checkbox Empty")
		case .filled:
			return App.current.recentlyViewedImages.get("Mission Checkbox Filled")
		case .disabledEmpty:
			return App.current.recentlyViewedImages.get("Mission Checkbox Empty (Disabled)")
		case .disabledFilled:
			return App.current.recentlyViewedImages.get("Mission Checkbox Filled (Disabled)")
		}
	}
}
