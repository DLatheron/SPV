//
//  BoolCell.swift
//  SPV
//
//  Created by dlatheron on 13/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class BoolCell : UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var boolButton: UISwitch!
}

extension BoolCell : SettingsCell {
    func configure(setting: Setting) {
        nameLabel.text = setting.name
        
        if let boolSetting = setting as? SettingT<Bool> {
            boolButton.isOn = boolSetting.value
        }
    }
}
