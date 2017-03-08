//
//  ValueDataRowDisplayable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/7/17.
//  Copyright © 2017 Emily Ivie. All rights reserved.
//

import UIKit

public protocol ValueDataRowDisplayable: IBViewable {
	var rowDivider: HairlineBorderView? { get set }
	var headingLabel: IBStyledLabel? { get set }
	var valueLabel: IBStyledLabel? { get set }
	var isHidden: Bool { get set }
	var top: Bool { get set }
	var bottom: Bool { get set }
	var showRowDivider: Bool { get }
	var isSettingUp: Bool { get set }
	var didSetup: Bool { get set }
	var onClick: ((UIButton)->Void)? { get set }
}

extension ValueDataRowDisplayable where Self: Spinnerable {
    func startParentSpinner(controller: UIViewController?) {
        guard !isInterfaceBuilder else { return }
        let parentView = (controller?.view is UITableView) ? controller?.view.superview : controller?.view
        DispatchQueue.main.async {
            self.startSpinner(inView: parentView)
        }
    }
    func stopParentSpinner(controller: UIViewController?) {
        guard !isInterfaceBuilder else { return }
        let parentView = (controller?.view is UITableView) ? controller?.view.superview : controller?.view
        DispatchQueue.main.async {
            self.stopSpinner(inView: parentView)
        }
    }
}
