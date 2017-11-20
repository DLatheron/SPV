//
//  SettingsCell.swift
//  SPV
//
//  Created by dlatheron on 13/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit

protocol SettingChangedDelegate {
    func changed(setting: Setting)
}

protocol SettingsCellDelegate {
    func configure(setting: Setting,
                   delegate: SettingChangedDelegate)
    
    func onClicked(viewController: SettingsViewController)
}

class SettingsCell : UITableViewCell {
    public var delegate: SettingChangedDelegate? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style,
                   reuseIdentifier: reuseIdentifier)
    }
}
