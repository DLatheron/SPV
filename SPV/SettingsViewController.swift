//
//  SettingsViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var settingsTableView: UITableView!
    
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
    
    func tableView(_ tableVvar: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return settingsBlock.settings.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settingAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: setting.editor,
                                                 for: indexPath)
        cell.selectionStyle = .none

        let cellDelegate = cell as! SettingsCellDelegate
        cellDelegate.configure(setting: setting,
                               delegate: self)
        
        return cell
    }
}

extension SettingsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! SettingsCellDelegate
        cell.onClicked(viewController: self)
    }
}

extension SettingsViewController {
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any?) {
        switch segue.identifier {
        case "SetPIN"?:
            let destVC = segue.destination as! PINEntryViewController
            destVC.completionBlock = { pin in
                print("Returned PIN was \(pin.asString)")
                self.settings.pin.value = pin.asString
                try? self.settings.save(toFileURL: Settings.defaultURL)
            }
            
        default:
            print("Unhandled segue \(segue.identifier ?? "Unknown")")
        }
    }
}

extension SettingsViewController : SettingChangedDelegate {
    func changed(setting: Setting) {
        try? Settings.shared.save(toFileURL: Settings.defaultURL)
    }
    
    func clicked(setting: SettingT<String>) {
        if setting.value == "SetPIN" {
            self.performSegue(withIdentifier: "SetPIN",
                              sender: self)
        }
    }
}

