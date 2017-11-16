//
//  TextCell.swift
//  SPV
//
//  Created by dlatheron on 15/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class TextCell : SettingsCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textBox: UITextField!
    
    var setting: SettingT<String>!
}

extension TextCell : SettingsCellDelegate {
    func configure(setting: Setting,
                   delegate: SettingChangedDelegate) {
        self.delegate = delegate
        self.setting = setting as! SettingT<String>
        
        nameLabel.text = self.setting.name
        textBox.text = self.setting.value
    }
}

extension TextCell : UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        
        setting.value = textField.text ?? ""
        delegate?.changed(setting: setting)
    }
}
