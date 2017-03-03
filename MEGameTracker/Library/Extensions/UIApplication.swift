//
//  UIApplication.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 9/15/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

//https://gist.github.com/snikch/3661188

extension UIApplication {
    /**
        Locates the top-most view controller available in App.current.
    */
    static var topViewController: UIViewController? {
        if let delegate = UIApplication.shared.delegate,
            let window = delegate.window {
            return window?.rootViewController
        }
        return nil
    }
}
