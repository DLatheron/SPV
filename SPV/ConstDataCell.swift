//
//  ConstDataCell.swift
//  SPV
//
//  Created by dlatheron on 16/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class ConstDataCell : SettingsCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    
    var setting: SettingT<Any>!
}

extension ConstDataCell : SettingsCellDelegate {
    func configure(setting: Setting,
                   delegate: SettingChangedDelegate) {
        self.setting = setting as! SettingT<Any>
        
        nameLabel.text = self.setting.name
        dataLabel.text = "\(self.setting.value)"
    }
}
