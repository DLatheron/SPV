//
//  SubMenuCell.swift
//  SPV
//
//  Created by dlatheron on 17/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class SubMenuCell : SettingsCell {
    @IBOutlet weak var nameLabel: UILabel!
    
    var setting: SettingsSubMenu!
}

extension SubMenuCell : SettingsCellDelegate {
    func configure(setting: Setting,
                   delegate: SettingChangedDelegate) {
        self.delegate = delegate
        self.setting = setting as! SettingsSubMenu
        
        nameLabel.text = self.setting.name
    }
}
