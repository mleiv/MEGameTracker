//
//  IBGradient.swift
//
//  Created by Emily Ivie on 9/17/16.
//
//  Licensed under The MIT License
//  For full copyright and license information, please see http://opensource.org/licenses/MIT
//  Redistributions of files must retain the above copyright notice.

import UIKit


/// Just a helpful way to define background gradients.
/// See CAGradientLayer for more information on the properties used here.
///
/// - direction: .Vertical or .Horizontal
/// - colors
/// - locations
/// - createGradientView()
public struct IBGradient {
    /// Quick enum to more clearly define IBGradient direction (Vertical or Horizontal).
    public enum Direction {
        case vertical, horizontal
    }
    public var direction: Direction = .vertical
    public var colors: [UIColor] = []
    public var locations: [Double] = []
    
    init(direction: Direction, colors: [UIColor]) {
        self.direction = direction
        self.colors = colors
    }
    
    /// Generates a IBGradientView from the gradient values provided.
    ///
    /// - parameter bounds:  The size to use in creating the gradient view.
    /// - returns:           a UIView with a gradient background layer
    public func createGradientView(_ bounds: CGRect) -> (IBGradientView) {
        let gradientView = IBGradientView(frame: bounds)
        gradientView.setLayerColors(colors)
        if !locations.isEmpty {
            gradientView.setLayerLocations(locations)
        } else {
            gradientView.setLayerEndPoint(direction == .vertical ? CGPoint(x: 0, y: 1) : CGPoint(x: 1, y: 0))
        }
        return gradientView
    }
}

//MARK: IBGradientView
/// Allows for an auto-resizable CAGradientLayer (like, say, during device orientation changes).
///
/// IBStyles IBStylePropertyName.BackgroundGradient uses this.
final public class IBGradientView: UIView {
    /// Built-in UIView function that responds to .layer requests.
    /// Changes the .layer property of the view to be CAGradientLayer. But we still have to change all interactions with .layer to recognize this new type, hence the other functions.
    ///
    /// returns: CAGradientLayer .layer reference
    override public class var layerClass : (AnyClass) {
        return CAGradientLayer.self
    }
    /// Sets the colors of the gradient. Can be more than two.
    ///
    /// parameter colors:  a list of UIColor elements.
    public func setLayerColors(_ colors: [UIColor]) {
        let layer = self.layer as? CAGradientLayer
        layer?.colors = colors.map({ $0.cgColor })
    }
    /// Sets the locations of the gradient. See CAGradientLayer documentation for how this work, because I only used endPoint myself.
    /// parameter locations:  a list of Double location positions.
    public func setLayerLocations(_ locations: [Double]) {
        let layer = self.layer as? CAGradientLayer
        layer?.locations = locations.map({ NSNumber(value: $0 as Double) })
    }
    /// Sets the start point of the gradient (this is the simplest way to define a gradient: setting the start or end point)
    /// 
    /// parameter startPoint:  a CGPoint using 0.0 - 1.0 values
    public func setLayerStartPoint(_ startPoint: CGPoint) {
        let layer = self.layer as? CAGradientLayer
        layer?.startPoint = startPoint
    }
    /// Sets the end point of the gradient (this is the simplest way to define a gradient: setting the start or end point)
    /// 
    /// parameter endPoint:  a CGPoint using 0.0 - 1.0 values
    public func setLayerEndPoint(_ endPoint: CGPoint) {
        let layer = self.layer as? CAGradientLayer
        layer?.endPoint = endPoint
    }
}
