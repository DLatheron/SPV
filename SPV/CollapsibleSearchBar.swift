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
    @IBInspectable var collapsedHeight: CGFloat = 26
    @IBInspectable var expandedHeight: CGFloat = 44
    
    private var textField: UITextField!
    private var textFieldBackground: UIView!
    
    private var _interpolant: CGFloat = 0.0
    @IBInspectable var interpolant: CGFloat {
        set {
            _interpolant = max(min(newValue, 1.0), 0.0)

            recalculateBounds()
            recalculateTextFieldAlpha()
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
    }
}

extension CollapsibleSearchBar {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        recalculateBounds()
        recalculateTextFieldAlpha()
    }
}

extension CollapsibleSearchBar {
    private func recalculateBounds() {
        let height = CollapsibleSearchBar.interpolate(from: expandedHeight,
                                                      to: collapsedHeight,
                                                      withProgress: interpolant)
        bounds = CGRect(x: bounds.origin.x,
                        y: bounds.origin.y,
                        width: bounds.size.width,
                        height: height)
    }
    
    private func recalculateTextFieldAlpha() {
        let alpha = CollapsibleSearchBar.interpolate(from: 1.0,
                                                     to: 0.0,
                                                     withProgress: interpolant,
                                                     minProgress: 0.0,
                                                     maxProgress: 0.2)
        textFieldBackground.alpha = alpha
//        . .alpha = 0.0
//        textField.background.isOpaque = false
//        if let colour = textField.textColor {
//            let newColour = colour.withAlphaComponent(alpha)
//            textField.textColor = newColour
//            textField.isOpaque = false
//        }
//        if let backgroundColour = subview.backgroundColor {
//            let newColour = backgroundColour.withAlphaComponent(backgroundAlpha)
//            subview.backgroundColor = newColour
//        }
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
