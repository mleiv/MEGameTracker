//
//  Delay.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 8/16/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import Foundation

public struct Delay {
    public static func bySeconds(_ seconds: Double, _ block: @escaping (()->Void)) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
    }
    public static func runAsync(seconds: Double, block: @escaping (()->Void)) {
        let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
        queue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: block)
    }
}
