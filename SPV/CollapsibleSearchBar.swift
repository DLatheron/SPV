//
//  CollapsibleSearchBar.swift
//  SPV
//
//  Created by dlatheron on 07/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

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
    override func layoutSubviews() {
        super.layoutSubviews()
        
        recalculate()
        
        print("layoutSubViews")
    }
}

extension CollapsibleSearchBar {
    private func calculateValues(interpolant: CGFloat) -> (height: CGFloat, alpha: CGFloat, scale: CGFloat, yOffset: CGFloat) {
        let height = CollapsibleSearchBar.interpolate(from: expandedHeight,
                                                      to: collapsedHeight,
                                                      withProgress: interpolant)
        let alpha = CollapsibleSearchBar.interpolate(from: 1.0,
                                                     to: 0.0,
                                                     withProgress: interpolant,
                                                     minProgress: 0.0,
                                                     maxProgress: 0.2)
        let scale = CollapsibleSearchBar.interpolate(from: expandedScale,
                                                     to: collapsedScale,
                                                     withProgress: interpolant)
        let yOffset = CollapsibleSearchBar.interpolate(from: expandedYOffset,
                                                       to: collapsedYOffset,
                                                       withProgress: interpolant)
        
        return (
            height: height,
            alpha: alpha,
            scale: scale,
            yOffset: yOffset
        )
    }
    
    func recalculate() {
        let values = calculateValues(interpolant: interpolant)
        
        bounds = CGRect(x: bounds.origin.x,
                        y: bounds.origin.y,
                        width: bounds.size.width,
                        height: values.height)
        
        textFieldBackground.alpha = values.alpha

        transform = CGAffineTransform(scaleX: values.scale, y: values.scale)
            .concatenating(CGAffineTransform(translationX: 0.0, y: values.yOffset))
    }
    
    func changeOrientation() {
        setNeedsLayout()
    }
    
    static func interpolate(from fromValue: CGFloat,
                            to toValue: CGFloat,
                            withProgress progress: CGFloat,
                            minProgress: CGFloat = 0.0,
                            maxProgress: CGFloat = 1.0) -> CGFloat {
        let rangeProgress = (progress - minProgress) / (maxProgress - minProgress)
        let clampedProgress = max(min(rangeProgress, 1), 0)
        
        return fromValue - ((fromValue - toValue) * clampedProgress)
    }
}

extension CollapsibleSearchBar {
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
