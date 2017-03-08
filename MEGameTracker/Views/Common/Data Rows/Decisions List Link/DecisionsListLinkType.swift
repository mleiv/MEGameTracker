//
//  DecisionsListLinkType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/19/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct DecisionsListLinkType: ValueDataRowType {
	public typealias RowType = ValueDataRow
	var view: RowType? { return row as? RowType }
    public var row: ValueDataRowDisplayable?

    public var identifier: String = "\(UUID().uuidString)"
    
    public var controller: DecisionsListLinkable?
    public var onClick: ((UIButton)->Void) = { _ in }
    
    public var heading: String? { return "Decisions" }
    public var viewController: UIViewController? { return controller as? UIViewController }
	
	public var isHideOnEmpty: Bool { return false }

    public init() {}
    public init(controller: DecisionsListLinkable, view: ValueDataRow?, onClick: @escaping ((_ sender: UIView?) -> Void)) {
        self.controller = controller
        self.row = view as? ValueDataRowDisplayable
		self.onClick = onClick
    }
	
	public mutating func setupView() {
		setupView(type: RowType.self)
	}
}

