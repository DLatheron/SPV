//
//  SettingsSubMenu.swift
//  SPV
//
//  Created by dlatheron on 17/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class SettingsSubMenu : Setting {
    var name: String
    
    let editor: String = "SubMenuCell"
    
    var settingsBlock: SettingsBlock
    
    init(_ settingsBlock: SettingsBlock) {
        self.name = settingsBlock.name
        self.settingsBlock = settingsBlock
    }
}
