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
    var alert: UIAlertController! = nil
    
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

extension SettingsViewController : SettingChangedDelegate {
    func changed(setting: Setting) {
        try? Settings.shared.save(toFileURL: Settings.defaultURL)
    }
    
    func clicked(setting: SettingT<String>) {
        switch setting.value {
        case "SetPIN":
            setNewPIN()
        case "ClearPIN":
            clearPIN()
        case "HTTPServer":
            httpServer(setting: setting)
            
        default:
            fatalError("Unknown button value: \(setting.value)")
        }
    }
    
    func httpServer(setting: SettingT<String>) {
        HTTPServer.shared.toggle() { address, error in
            DispatchQueue.main.async {
                if let error = error {
                    setting.name = "HTTP Server Errored"
                    print("HTTP Server errored: \(error)")
                } else if let address = address {
                    setting.name = "HTTP Server Online: \(address)"
                    print("HTTP Server online at \(address)")
                } else {
                    setting.name = "Start HTTP Server"
                    print("HTTP Server offline")
                }
                self.settingsTableView.reloadData()
            }
        }
    }
    
    func setNewPIN() {
        var navigationController: UINavigationController? = nil
        
        func _requestNew() {
            self.requestAuthentication(
                navController: &navigationController,
                entryMode: .setPIN,
                completionBlock: { (success, pin) in
                    if success {
                        AuthenticationService.shared.register(pin: pin!)

                        self.displayPINUpdatedAlert(onViewController: (navigationController?.viewControllers.last)!) {
                            navigationController!.dismiss(animated: true) {
                            }
                        }
                    } else {
                        navigationController!.dismiss(animated: true) {
                        }                        
                    }
            })
        }
        
        if AuthenticationService.shared.pinHasBeenSet {
            self.requestAuthentication(
                navController: &navigationController,
                entryMode: .pin,
                completionBlock: { success, pin in
                    if success {
                        _requestNew()
                    } else {
                        print("PIN update cancelled")
                    }
            })
        } else {
            _requestNew()
        }
    }
    
    func clearPIN() {
        if AuthenticationService.shared.pinHasBeenSet {
            var navigationController: UINavigationController? = nil
            self.requestAuthentication(navController: &navigationController,
                                       entryMode: .pin,
                                       completionBlock: { (success, pin) in
                if success {
                    AuthenticationService.shared.clear()
                    
                    self.displayPINClearedAlert(onViewController: (navigationController?.viewControllers.last)!) {
                        navigationController!.dismiss(animated: true) {
                        }
                    }

                }
            })
        }
    }
    
    func displayAlert(onViewController viewController: UIViewController,
                      title: String,
                      message: String,
                      then: @escaping () -> Void) {
        alert = UIAlertController(title: title,
                                  message: message,
                                  preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default) { action in
            then()
        })
        viewController.present(alert,
                               animated: true)

    }
    
    func displayPINUpdatedAlert(onViewController viewController: UIViewController,
                                then: @escaping () -> Void) {
        displayAlert(onViewController: viewController,
                     title: "Success",
                     message: "PIN was updated!",
                     then: then)
    }

    
    func displayPINClearedAlert(onViewController viewController: UIViewController,
                                then: @escaping () -> Void) {
        displayAlert(onViewController: viewController,
                     title: "Success",
                     message: "PIN was cleared",
                     then: then)
    }
    
    func requestAuthentication(
        navController: inout UINavigationController?,
        entryMode: PINEntryMode,
        completionBlock: @escaping ((Bool, PIN?) -> ())
    ) {
        let authenticationService = AuthenticationService.shared
        let storyboard = UIStoryboard(name: "Authentication",
                                      bundle: nil)
        let authenticationVC: AuthenticationViewController
        
        if navController == nil {
            navController = storyboard.instantiateViewController(
                withIdentifier: "Authentication"
            ) as? UINavigationController
            
            authenticationVC = navController!.viewControllers[0] as! AuthenticationViewController

            authenticationVC.authenticationService = authenticationService
            authenticationVC.authenticationDelegate = authenticationService
            authenticationVC.entryMode = entryMode
            authenticationVC.completionBlock = completionBlock
            
            self.present(navController!,
                         animated: true,
                         completion: nil)
        } else {
            authenticationVC = storyboard.instantiateViewController(
                withIdentifier: "AuthenticationViewController"
            ) as! AuthenticationViewController
            
            authenticationVC.authenticationService = authenticationService
            authenticationVC.authenticationDelegate = authenticationService
            authenticationVC.entryMode = entryMode
            authenticationVC.completionBlock = completionBlock
            
            navController!.pushViewController(authenticationVC,
                                              animated: true)
        }
    }
}

