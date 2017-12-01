//
//  PINButton.swift
//  SPV
//
//  Created by dlatheron on 29/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

@objc protocol PINButtonDelegate {
    func pressed(character: String)
}

class PINButton : UIButton {
    @IBOutlet var character: String!
    @IBOutlet var delegate: PINButtonDelegate? = nil
    
    var initialBackgroundColour: UIColor!
    var initialForegroundColour: UIColor!

    var willBeClicked = false

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
        
        layer.cornerRadius = bounds.size.height / 2
        clipsToBounds = true
        titleLabel?.numberOfLines = 0
        
        self.addTarget(self,
                       action: #selector(touchDown(_:)),
                       for: .touchDown)
        self.addTarget(self,
                       action: #selector(touchUpInside(_:)),
                       for: .touchUpInside)
        self.addTarget(self,
                       action: #selector(touchDragOutside(_:)),
                       for: .touchDragOutside)
        self.addTarget(self,
                       action: #selector(touchUpOutside(_:)),
                       for: .touchUpOutside)
    }
    
    @objc func touchDown(_ sender: Any) {
        highlight()
    }
    
    @objc func touchUpInside(_ sender: Any) {
        if unhighlight() {
            delegate?.pressed(character: character)
        }
    }
    
    @objc func touchUpOutside(_ sender: Any) {
        _ = unhighlight()
    }
    
    @objc func touchDragOutside(_ sender: Any) {
        _ = unhighlight()
    }
    
    func highlight() {
        recolourButton(textColour: initialBackgroundColour,
                       backgroundColour: initialForegroundColour)
        willBeClicked = true
    }
    
    func unhighlight() -> Bool {
        let clicked = willBeClicked
        recolourButton(textColour: initialForegroundColour,
                       backgroundColour: initialBackgroundColour)
        willBeClicked = false
        return clicked
    }
    
    func recolourButton(textColour: UIColor,
                        backgroundColour: UIColor) {
        self.backgroundColor = backgroundColour
        self.tintColor = textColour
        
        if let titleLabel = titleLabel,
            let existingAttributedText = titleLabel.attributedText {
            let fullRange = NSRange(location: 0,
                                    length: existingAttributedText.length)
            let newAttributedText = NSMutableAttributedString(attributedString: existingAttributedText)
            newAttributedText.addAttribute(NSAttributedStringKey.foregroundColor,
                                            value: textColour,
                                            range: fullRange)
            setAttributedTitle(newAttributedText,
                               for: .normal)
        } else {
            backgroundColor = backgroundColour
            tintColor = textColour
        }
    }
}
