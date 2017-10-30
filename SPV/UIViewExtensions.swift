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
}
