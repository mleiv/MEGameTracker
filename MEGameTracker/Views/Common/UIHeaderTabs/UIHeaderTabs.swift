//
//  UIHeaderTabs.swift
//
//  Created by Emily Ivie on 9/10/15.
//  Copyright © 2015 urdnot.

//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit

@IBDesignable final public class UIHeaderTabs: UIView {

	@IBInspectable public var text: String?

	lazy var inspectableData: [String] = { return self.dataFromText() }()

	var segmentTitles: [String]?
	var selectedSegmentIndex: Int = 0
	var onClick: ((Int) -> Void)?

	var didSetup = false
	fileprivate var nib: UIHeaderTabsNib?

//	public override func layoutSubviews() {
//		if !didSetup {
//			setupTabs()
//		}

//		super.layoutSubviews()
//	}

	public func setup(segmentTitles: [String]? = nil, selectedSegmentIndex: Int? = nil, onClick: ((Int) -> Void)? = nil) {
		self.segmentTitles = segmentTitles
		self.selectedSegmentIndex = selectedSegmentIndex ?? self.selectedSegmentIndex
		self.onClick = onClick
		setupTabs()
	}

	public func change(segmentTitles: [String]) {
		self.segmentTitles = segmentTitles
		setupTabs()
	}

	public func change(selectedSegmentIndex: Int) {
		self.selectedSegmentIndex = selectedSegmentIndex
		setupTabs()
	}

	public func change(onClick: ((Int) -> Void)?) {
		self.onClick = onClick
		setupTabs()
	}

	internal func setupTabs() {
		if nib == nil, let view = UIHeaderTabsNib.loadNib() {
			insertSubview(view, at: 0)
			view.fillView(self)
			nib = view
		}
		if let view = nib {
			let titles = segmentTitles ?? inspectableData
			view.setupTabs(titles.count)
			for (index, tab) in view.tabs.enumerated() {
				tab.setup(
					title: titles[index],
					selected: selectedSegmentIndex == index ? true : false,
					index: index,
					onClick: onClick
				)
			}
			didSetup = true
			layoutIfNeeded()
		}
	}

	fileprivate func dataFromText() -> [String] {
		if text?.range(of: ",") != nil {
			return (text ?? "").components(separatedBy: ",").map { String($0) }
		}
		return []
	}
}
@IBDesignable open class UIHeaderTabsNib: UIView {

	@IBOutlet weak var sampleTabWrapper: UIView!
	@IBOutlet weak var sampleTabStack: UIStackView!
	open var tabs = [UIHeaderTab]()

	open func setupTabs(_ count: Int) {
		tabs = []
		for element in sampleTabStack.arrangedSubviews {
			element.removeFromSuperview()
		}
		let bundle = Bundle(for: type(of: self))
		for index in 0..<count {
			if let tab =  bundle.loadNibNamed("UIHeaderTab", owner: self, options: nil)?.first as? UIHeaderTab {
				tab.setup(title: "Tab \(index + 1)", index: index)
				tabs.append(tab)
				sampleTabStack.addArrangedSubview(tab)
			}
		}
		sampleTabWrapper.frame.size.height = tabs[0].frame.height
	}

	open class func loadNib() -> UIHeaderTabsNib? {
		let bundle = Bundle(for: UIHeaderTabsNib.self)
		if let view = bundle.loadNibNamed("UIHeaderTabsNib", owner: self, options: nil)?.first as? UIHeaderTabsNib {
			return view
		}
		return nil
	}
}
