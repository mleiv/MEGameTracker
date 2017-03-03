//
//  SpinnerNib.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 5/14/2016.
//  Copyright © 2016 urdnot. All rights reserved.
//

import UIKit

final public class SpinnerNib: UIView {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView?
    @IBOutlet weak var spinnerLabel: MarkupLabel?
    @IBOutlet weak var spacerView: UIView?
    @IBOutlet public weak var progressView: UIProgressView?
    
    var title: String? {
        didSet {
            if oldValue != title {
                setupTitle()
            }
        }
    }
    var isShowProgress: Bool = false {
        didSet {
            if oldValue != isShowProgress {
                setupProgress()
            }
        }
    }
    
    public func setup() {
        setupTitle()
        setupProgress()
    }
    
    public func setupTitle() {
        spinnerLabel?.text = title
        spinnerLabel?.isHidden = !(title?.isEmpty == false)
        layoutIfNeeded()
    }
    
    public func setupProgress() {
        spacerView?.isHidden = !isShowProgress
        progressView?.isHidden = !isShowProgress
        layoutIfNeeded()
    }
    
    public func start() {
        setupProgress()
        progressView?.progress = 0.0
        spinner?.startAnimating()
        isHidden = false
    }
    
    public func startSpinning() {
        spinner?.startAnimating()
        progressView?.progress = 0.0
    }
    
    public func stop() {
        spinner?.stopAnimating()
        isHidden = true
    }
    
    public func updateProgress(percentCompleted: Int) {
        let decimalCompleted = Float(percentCompleted) / 100.0
        progressView?.setProgress(decimalCompleted, animated: true)
    }
    
    public func changeMessage(_ title: String) {
        spinnerLabel?.text = title
        layoutIfNeeded()
    }
    
    public class func loadNib(title: String? = nil) -> SpinnerNib? {
        let bundle = Bundle(for: SpinnerNib.self)
        if let view = bundle.loadNibNamed("SpinnerNib", owner: self, options: nil)?.first as? SpinnerNib {
            view.spinner?.color = Styles.Colors.tintColor
            view.title = title
            return view
        }
        return nil
    }
}
