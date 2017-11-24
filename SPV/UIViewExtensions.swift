//
//  ViewExtensions.swift
//  SPV
//
//  Created by dlatheron on 18/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func getSubview(byType type: String) -> UIView? {
        for view in self.subviews {
            if view.isKind(of: NSClassFromString(type)!) {
                return view
            }
            
            // Recurse into view's subviews.
            let subview = view.getSubview(byType: type)
            if (subview != nil) {
                return subview
            }
        }

        return nil
    }
    
    func shake(completionHandler: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completionHandler?()
        }
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [ -20, 20, -20, 20, -10, 10, -5, 5, 0 ]
        self.layer.add(animation,
                       forKey:"shake")
        CATransaction.commit()
    }
}
