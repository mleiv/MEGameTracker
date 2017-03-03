//
//  Calloutsable.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 6/9/16.
//  Copyright © 2016 Emily Ivie. All rights reserved.
//

import UIKit

public protocol Calloutsable: class {

    var inMap: Map? { get }
    var callouts: [MapLocationable] { get set }
    var viewController: UIViewController? { get }
    var navigationPushController: UINavigationController? { get }
//    var originHint: String? { get }
    
    // handles onChange, select internally
}

