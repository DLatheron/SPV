//
//  BaseTabBBarController.swift
//  SPV
//
//  Created by dlatheron on 01/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class BaseTabBarController: UITabBarController {
    
    @IBInspectable var defaultIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = defaultIndex
    }
    
}
