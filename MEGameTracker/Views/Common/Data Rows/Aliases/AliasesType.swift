//
//  AliasesType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/27/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct AliasesType: TextDataRowType {
	public typealias RowType = TextDataRow
	var view: RowType? { return row }
	public var row: TextDataRow?

	public var identifier: String = "\(UUID().uuidString)"

	public var controller: Aliasable?

	public var text: String? {
		if UIWindow.isInterfaceBuilder {
			return String(format: knownAliasesTitle, "UNC: Missing Persons")
		} else if let aliases = controller?.aliases.filter({ $0 != controller?.currentName }), !aliases.isEmpty {
			return String(format: knownAliasesTitle, aliases.joined(separator: ", "))
		}
		return nil
	}

	let knownAliasesTitle = "Known Aliases: _%@_"

	let defaultPaddingTop: CGFloat = 0.0

	var viewController: UIViewController? { return controller as? UIViewController }

	public init() {}
	public init(controller: Aliasable, view: TextDataRow?) {
		self.controller = controller
		self.row = view
	}

	public mutating func setupView() {
		setupView(type: RowType.self)
	}

	public mutating func setup(view: UIView?) {
		guard let view = view as? RowType else { return }
		if view.didSetup != true {
			view.textView?.identifier = "Caption.DisabledColor"
			view.topPaddingConstraint?.constant = defaultPaddingTop
		}
	}
}
