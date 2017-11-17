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
    var settingsBlock: SettingsBlock!
    
    required init?(coder aDecoder: NSCoder) {
        settingsBlock = settings.settingsBlock

        super.init(coder: aDecoder)
    }
}

extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension SettingsViewController {
    func settingAt(indexPath: IndexPath) -> Setting {
        return settingsBlock.settings[indexPath.row]
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
        return settingsBlock.settings.count
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
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let settings = settingAt(indexPath: indexPath)
        if let settings = settings as? SettingsSubMenu {
            // How do we push a submenu into this controller???
            let subSettingsVC = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            subSettingsVC.settingsBlock = settings.settingsBlock
            subSettingsVC.title = settings.settingsBlock.name
            
            self.navigationController!.pushViewController(subSettingsVC,
                                                          animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        if segue.identifier == "SettingsViewController" {
        }
    }
}

extension SettingsViewController : SettingChangedDelegate {
    func changed(setting: Setting) {
        try? Settings.shared.save(toFileURL: Settings.defaultURL)
    }
}

