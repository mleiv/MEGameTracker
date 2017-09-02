//
//  MapLinkType.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

public struct MapLinkType: ValueDataRowType {
	public typealias RowType = ValueDataRow
	var view: RowType? { return row as? ValueDataRow }
	public var row: ValueDataRowDisplayable?

	public var identifier: String = "\(UUID().uuidString)"

	public var controller: MapLinkable?
	public var onClick: ((UIButton) -> Void) = { _ in }

	public var heading: String? { return "Map" }
	public var value: String? {
		if UIWindow.isInterfaceBuilder {
			return "Omega Nebula > Sahrabarik"
		} else if let map = self.map {
			let parentBreadcrumbs: [String] = map.getBreadcrumbs().map({ $0.name }).filter({ $0 != "Galaxy Map" })
			return (parentBreadcrumbs + [map.name]).joined(separator: " > ")
		} else {
			return nil
		}
	}
	public var originHint: String? { return controller?.originHint }
	public var viewController: UIViewController? { return controller as? UIViewController }

	private var map: Map?

	public init() {}
	public init(controller: MapLinkable, view: ValueDataRow?) {
		self.controller = controller
		self.row = view
	}

	public mutating func initMapAndClick() {
		guard !UIWindow.isInterfaceBuilder  else { return }
		if map?.id != controller?.inMapId, let inMapId = controller?.inMapId {
			map = Map.get(id: inMapId)
		} else if controller?.inMapId == nil {
			map = nil
		}
		let selfCopy = self
		let mapCopy = self.map
		self.onClick = { sender in
			selfCopy.openRow(sender: sender, map: mapCopy)
		}
	}

	public mutating func setupView() {
		initMapAndClick()
		setupView(type: RowType.self)
	}

	public func openRow(sender: UIView?, map: Map?) {
		guard let view = view, let controller = controller else { return }
		var map = map
		view.startParentSpinner(controller: viewController)
		DispatchQueue.global(qos: .background).async {
			var mapLocation = controller.mapLocation
			if let _ = mapLocation, mapLocation?.mapLocationPoint == nil {
				mapLocation?.mapLocationPoint = map?.mapLocationPoint
			}
			if controller.isShowInParentMap == true, let inMapId = map?.inMapId {
                let gameVersion = map?.gameVersion ?? App.current.gameVersion
//				mapLocation = map // mission/item should show now in map
				map = Map.get(id: inMapId)
			}
			let bundle = Bundle(for: type(of: view))
			if let flowController = UIStoryboard(name: "MapsFlow", bundle: bundle)
					.instantiateViewController(withIdentifier: "Map") as? MapsFlowController,
				let mapController = flowController.includedController as? MapSplitViewController {
				// configure detail
				mapController.map = map
				mapController.mapLocation = mapLocation
				mapController.referringOriginHint = controller.originHint
				DispatchQueue.main.async {
					self.viewController?.navigationController?.pushViewController(flowController, animated: true)
					view.stopParentSpinner(controller: self.viewController)
				}
				return
			}
			view.stopParentSpinner(controller: self.viewController)
		}
	}
}
