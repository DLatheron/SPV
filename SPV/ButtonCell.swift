//
//  ButtonCell.swift
//  SPV
//
//  Created by dlatheron on 20/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class ButtonCell : SettingsCell {
    @IBOutlet weak var button: UIButton!
    
    var setting: SettingT<String>!
}

extension ButtonCell : SettingsCellDelegate {
    func configure(setting: Setting,
                   delegate: SettingChangedDelegate) {
        self.delegate = delegate
        self.setting = setting as! SettingT<String>
        
        button.setTitle(self.setting.name,
                        for: .normal)
    }
    
    func onClicked(viewController: SettingsViewController) {
    }
    
    @IBAction func clickButton(_ sender: Any) {
        self.delegate?.clicked(setting: setting)
    }
}
