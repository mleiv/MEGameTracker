//
//  SliderRow.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

@IBDesignable
final public class SliderRow: HairlineBorderView, IBViewable {

// MARK: Inspectable
	@IBInspectable public var headingPattern: String = "%d/%d: " {
		didSet { setDummyDataRowType() }
	}
	@IBInspectable public var showRowDivider: Bool = false
	@IBInspectable public var isHideOnEmpty: Bool = true

	var value: Int = 1
	var minValue: Int = 0
	var maxValue: Int = 1
	var onChangeBlock: ((_ sliderValue: Int) -> Void)?

// MARK: Outlets
	@IBOutlet weak var headingLabel: UILabel?
	@IBOutlet weak var slider: UISlider?
	@IBOutlet weak var rowDivider: HairlineBorderView?
	@IBAction func onChange(_ sender: UISlider?) {
		sliderChanged(sender)
	}
	@IBAction func onFinishedChange(_ sender: UISlider?) {
		sliderFinishedChanging(sender)
	}

// MARK: Properties
	public var didSetup = false
	public var isSettingUp = false

	// Protocol: IBViewable
	public var isAttachedNibWrapper = false
	public var isAttachedNib = false

// MARK: IBViewable

	override public func awakeFromNib() {
		super.awakeFromNib()
		_ = attachOrAttachedNib()
	}

	override public func prepareForInterfaceBuilder() {
		_ = attachOrAttachedNib()
		super.prepareForInterfaceBuilder()
	}

// MARK: Hide when not initialized (as though if empty)

	public override func layoutSubviews() {
		setDummyDataRowType()
		super.layoutSubviews()
	}

	public func initialize(
		value: Int,
		minValue: Int,
		maxValue: Int,
		onChange: ((_ sliderValue: Int) -> Void)? = nil
	) {
		self.value = value
		self.minValue = minValue
		self.maxValue = maxValue
		self.onChangeBlock = onChange
	}

	public func setupView() {
		guard let view = attachOrAttachedNib(),
			!view.isSettingUp else { return }
		view.isSettingUp = true

		view.value = value
		view.minValue = minValue
		view.maxValue = maxValue
		view.headingPattern = headingPattern
		view.onChangeBlock = onChangeBlock

		view.rowDivider?.isHidden = !showRowDivider

		view.setup()

		view.isSettingUp = false
		didSetup = true
	}

	public func setup() {
		guard isAttachedNib else { return }
		slider?.minimumValue = Float(minValue)
		slider?.maximumValue = Float(maxValue)
		slider?.value = Float(value)
		headingLabel?.text = String(format: headingPattern, value, maxValue)
	}

// MARK: Actions

	public func sliderChanged(_ sender: UIView?) {
		value = Int((sender as? UISlider)?.value ?? 1)
		setup()
	}

	public func sliderFinishedChanging(_ sender: UIView?) {
		value = Int((sender as? UISlider)?.value ?? 1)
		onChangeBlock?(value)
	}

// MARK: Preview Options

	private func setDummyDataRowType() {
		guard (isInterfaceBuilder || App.isInitializing) && !didSetup && isAttachedNibWrapper else { return }
		switch headingPattern {
			case "Paragon %d%%: ": fallthrough
			case "Renegade %d%%: ":
				maxValue = 100
				value = 0
			default:
				minValue = 1
				maxValue = 30
		}
		setupView()
	}
}
