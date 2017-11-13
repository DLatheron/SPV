//
//  SettingsViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit

protocol Setting {
    var name: String { get }
    var cellId: String { get }
}

class SettingT<T> : Setting {
    var name: String
    var value: T
    
    var cellId: String {
        get {
            return "BoolCell"
        }
    }
    
    
    init(name: String,
         value: T) {
        self.name = name
        self.value = value
    }
}

class SettingsViewController: UIViewController {
    var settings: [Setting] = [
        SettingT<Bool>(name: "Test One", value: true)
    ]
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
        return settings[indexPath.row]
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
        return settings.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let setting = settingAt(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: setting.cellId,
                                                 for: indexPath) as! SettingsCell
        cell.configure(setting: setting)
        
        return cell as! UITableViewCell
    }
}

extension SettingsViewController : UITableViewDelegate {
    
}
