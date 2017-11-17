//
//  TextBlockCell.swift
//  SPV
//
//  Created by dlatheron on 17/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class TextBlockCell : SettingsCell {
    @IBOutlet weak var textBox: UITextView!
    
    var setting: SettingT<String>!
}

extension TextBlockCell : SettingsCellDelegate {
    func configure(setting: Setting,
                   delegate: SettingChangedDelegate) {
        self.delegate = delegate
        self.setting = setting as! SettingT<String>
        
        textBox.text = self.setting.value
    }
}
