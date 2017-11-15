//
//  BoolCell.swift
//  SPV
//
//  Created by dlatheron on 13/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class BoolCell : SettingsCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var boolButton: UISwitch!
    
    var setting: SettingT<Bool>!
}

extension BoolCell : SettingsCellDelegate {
    func configure(setting: Setting,
                   delegate: SettingChangedDelegate) {
        self.delegate = delegate
        self.setting = setting as! SettingT<Bool>
        
        nameLabel.text = setting.name
        
        if let boolSetting = setting as? SettingT<Bool> {
            boolButton.isOn = boolSetting.value
        }
    }
    
    @IBAction func changeSwitch(_ sender: Any) {
        setting.value = boolButton.isOn
        delegate?.changed(setting: setting)
    }
}
