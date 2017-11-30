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
            if filled {
                showFilled()
            } else {
                showEmpty()
            }
        }
    }
    
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
    
    func configureLook() {
        initialBackgroundColour = backgroundColor ?? UIColor.clear
        initialForegroundColour = tintColor
        layer.cornerRadius = 6
        showEmpty()
    }
}

extension PINDigit {
    func showFilled() {
        self.backgroundColor = initialForegroundColour
        self.tintColor = initialBackgroundColour
    }
    
    func showEmpty() {
        self.backgroundColor = initialBackgroundColour
        self.tintColor = initialForegroundColour
    }
}
