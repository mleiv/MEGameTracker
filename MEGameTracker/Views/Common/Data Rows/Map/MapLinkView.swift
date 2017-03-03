//
//  MapLinkView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 3/14/16.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class MapLinkView: SimpleValueDataRow {
    
    public var controller: MapLinkable? {
        didSet {
            reloadData()
        }
    }
    public var map: Map?
    
    override var heading: String? { return "Map" }
    override var value: String? {
        if UIWindow.isInterfaceBuilder {
            return "Omega Nebula > Sahrabarik"
        } else if let map = self.map {
            let parentBreadcrumbs: [String] = map.getBreadcrumbs().map({ $0.name }).filter({ $0 != "Galaxy Map" })
            return (parentBreadcrumbs + [map.name]).joined(separator: " > ")
        } else {
            return nil
        }
    }
    override var originHint: String? { return controller?.originHint }
    override var viewController: UIViewController? { return controller as? UIViewController }
    
    override public func reloadData() {
        if UIWindow.isInterfaceBuilder {
            return
        } else if map?.id != controller?.inMapId, let inMapId = controller?.inMapId {
            DispatchQueue.global(qos: .background).async {
                self.map = Map.get(id: inMapId)
                if self.didSetup {
                    DispatchQueue.main.async {
                        self.reloadData()
                    }
                }
            }
            return
        } else if controller?.inMapId == nil {
            map = nil
        }
        super.reloadData()
    }
    
    override func openRow(sender: UIView?) {
        startParentSpinner()
        DispatchQueue.global(qos: .background).async {
            var map = self.map
            var mapLocation = self.controller?.mapLocation
            if let _ = mapLocation , mapLocation?.mapLocationPoint == nil {
                mapLocation?.mapLocationPoint = map?.mapLocationPoint
            }
            if self.controller?.isShowInParentMap == true, let inMapId = map?.inMapId {
//                mapLocation = map // mission/item should show now in map
                map = Map.get(id: inMapId)
            }
            if let flowController = UIStoryboard(name: "MapsFlow", bundle: Bundle(for: type(of: self))).instantiateViewController(withIdentifier: "Map") as? MapsFlowController,
                let mapController = flowController.includedController as? MapSplitViewController {
                // configure detail
                mapController.map = map
                mapController.mapLocation = mapLocation
                mapController.referringOriginHint = self.controller?.originHint
                DispatchQueue.main.async {
                    self.viewController?.navigationController?.pushViewController(flowController, animated: true)
                    self.stopParentSpinner()
                }
                return
            }
            self.stopParentSpinner()
        }
    }
}


