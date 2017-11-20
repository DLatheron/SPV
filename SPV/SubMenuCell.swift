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
    
    func onClicked(viewController: SettingsViewController) {
        let subSettingsVC = viewController.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
        subSettingsVC.settingsBlock = self.setting.settingsBlock
        subSettingsVC.title = self.setting.settingsBlock.name
        
        viewController.navigationController!.pushViewController(subSettingsVC,
                                                                animated: true)
    }
}
