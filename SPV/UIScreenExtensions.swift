//
//  UIScreenExtensions.swift
//  SPV
//
//  Created by dlatheron on 30/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

extension UIScreen {
    var isLandscape: Bool {
        get {
            let screenSize = bounds.size
            return screenSize.width > screenSize.height
        }
    }
    
    var orientation: UIInterfaceOrientation {
        get {
            let point = coordinateSpace.convert(CGPoint.zero,
                                                to: fixedCoordinateSpace)
            if point == CGPoint.zero {
                return .portrait
            } else if point.x != 0 && point.y != 0 {
                return .portraitUpsideDown
            } else if point.x == 0 && point.y != 0 {
                return .landscapeLeft
            } else if point.x != 0 && point.y == 0 {
                return .landscapeRight
            } else {
                return .unknown
            }
        }
    }
}
