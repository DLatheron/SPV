//
//  PINDigit.swift
//  SPV
//
//  Created by dlatheron on 29/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class PINDigit : UIView {
    var filled: Bool = false {
        didSet {
            filledView.isHidden = !filled
        }
    }
    
    var filledView: UIView!
    var initialBackgroundColour: UIColor!
    var initialForegroundColour: UIColor!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLook()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureLook()
    }
}

extension PINDigit {
    
    func configureLook() {
        initialBackgroundColour = backgroundColor ?? UIColor.clear
        initialForegroundColour = tintColor
        layer.cornerRadius = 6
        
        filledView = subviews[0]
        filledView.layer.cornerRadius = filledView.bounds.size.width / 2
        filledView.backgroundColor = filledView.tintColor
        filled = !(!filled)
    }
}
