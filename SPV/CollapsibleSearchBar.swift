//
//  CollapsibleSearchBar.swift
//  SPV
//
//  Created by dlatheron on 07/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

// If we make the height of the bar the interpolant for the alpha, will that
// help?

class CollapsibleSearchBar : UISearchBar {
    @IBInspectable var collapsedHeight: CGFloat = 20
    @IBInspectable var expandedHeight: CGFloat = 44
    @IBInspectable var expandedScale: CGFloat = 1
    @IBInspectable var collapsedScale: CGFloat = 0.75
    @IBInspectable var expandedYOffset: CGFloat = 0
    @IBInspectable var collapsedYOffset: CGFloat = 11
    @IBInspectable var snapThreshold: CGFloat = 0.5
    
    private var textField: UITextField!
    private var textFieldBackground: UIView!
    
    private (set) var editing: Bool = false {
        didSet {
            _urlStringUpdated()
        }
    }
    var urlString: String? = nil {
        didSet {
            _urlStringUpdated()
        }
    }
    
    private var _interpolant: CGFloat = 0.0
    @IBInspectable var interpolant: CGFloat {
        set {
            _interpolant = max(min(newValue, 1.0), 0.0)

            recalculate()
        }
        
        get {
            return _interpolant
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        textField = value(forKey: "searchField") as! UITextField
        textFieldBackground = textField.subviews[0]

        textField.leftViewMode = .never
        textField.clearButtonMode = .whileEditing
        textField.rightViewMode = .whileEditing
        
        _urlStringUpdated()
    }
}

extension CollapsibleSearchBar {
    override var bounds: CGRect {
        didSet {
            print("Bounds changed to \(bounds)")
            
            let height = bounds.size.height
            let ratio = (height - collapsedHeight) / (expandedHeight - collapsedHeight)
            let interpolant = max(min(1.0 - ratio, 1.0), 0.0)
            
            print("Interpolant is now \(interpolant)")
            
            let values = calculateValues(interpolant: interpolant)
            
            textFieldBackground.alpha = values.alpha
            
            transform = CGAffineTransform(scaleX: values.scale, y: values.scale)
                .concatenating(CGAffineTransform(translationX: 0.0, y: values.yOffset))
            
            // We need to affect height externally.
            
            setNeedsLayout()
            
            textField.isUserInteractionEnabled = interpolant == 0.0
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        //recalculate()
    }
}

extension CollapsibleSearchBar {
    private func calculateValues(interpolant: CGFloat) -> (alpha: CGFloat, scale: CGFloat, yOffset: CGFloat) {
        let alpha = Interpolator.interpolate(from: 1.0,
                                             to: 0.0,
                                             withProgress: interpolant,
                                             minProgress: 0.0,
                                             maxProgress: 0.2)
        let scale = Interpolator.interpolate(from: expandedScale,
                                             to: collapsedScale,
                                             withProgress: interpolant)
        let yOffset = Interpolator.interpolate(from: expandedYOffset,
                                               to: collapsedYOffset,
                                               withProgress: interpolant)
        
        return (
            alpha: alpha,
            scale: scale,
            yOffset: yOffset
        )
    }
    
    func recalculate() {
        let values = calculateValues(interpolant: interpolant)
        
        textFieldBackground.alpha = values.alpha

        transform = CGAffineTransform(scaleX: values.scale,
                                      y: values.scale)
            .concatenating(CGAffineTransform(translationX: 0.0,
                                             y: values.yOffset))
    }
    
    func changeOrientation() {
        setNeedsLayout()
    }
}

extension CollapsibleSearchBar {
//    func expandAndActivate(completionBlock: @escaping (() -> Void)) {
//        interpolant = 0
//        activate()
//        completionBlock()
//    }
    
    func activate() {
        setShowsCancelButton(true,
                             animated: true)
        editing = true
    }
    
    func deactivate() {
        resignFirstResponder()
        setShowsCancelButton(false,
                             animated: true)
        editing = false
    }
}

extension CollapsibleSearchBar {
    var url: URL? {
        get {
            if let urlString = urlString {
                return URL(string: urlString)
            } else {
                return nil
            }
        }
        
        set {
            urlString = newValue?.absoluteString
        }
    }
    
    private func _urlStringUpdated() {
        if editing {
            textField.textAlignment = .left
            text = urlString
        } else {
            textField.textAlignment = .center

            if let urlString = urlString {
                let closedLock = "🔒"
                let openLock = ""
                
                if let urlBuilder = URLBuilder(string: urlString) {
                    let lockState = urlBuilder.isSchemeSecure ? closedLock : openLock
                    let domainText = "\(lockState) \(urlBuilder.host ?? "")"
                    text = domainText
                } else {
                    text = nil
                }
            } else {
                text = nil
            }
        }
    }
}

extension CollapsibleSearchBar {
    func snap() -> CGFloat {
        if interpolant <= snapThreshold {
            return 0.0
        } else {
            return 1.0
        }
    }
}
