//
//  EmbeddedMediaView.swift
//  SPV
//
//  Created by dlatheron on 22/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoScrollViewDelegate {
    var isFullscreen: Bool {
        get
    }
}

protocol EmbeddedMediaViewDelegate {
    var isFullyZoomedOut: Bool {
        get
    }
    
    var view: UIView {
        get
    }
    
    func willRotate(parentView: UIView)
    func didRotate(parentView: UIView)
    func remove()
    
    func singleTap()
    func doubleTap()
}
