//
//  SettingsViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    var settings: Settings = Settings.shared
}

extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingsViewController {
    func settingAt(indexPath: IndexPath) -> Setting {
        return settings.settings[indexPath.row]
    }
}

extension SettingsViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return [ "" ]
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return settings.settings.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settingAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: setting.editor,
                                                 for: indexPath) as! SettingsCellDelegate
        cell.configure(setting: setting,
                       delegate: self)
        
        return cell as! UITableViewCell
    }
}

extension SettingsViewController : UITableViewDelegate {
}

extension SettingsViewController : SettingChangedDelegate {
    func changed(setting: Setting) {
        try? Settings.shared.save(toFileURL: Settings.defaultURL)
    }
}
