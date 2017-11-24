//
//  PINEntryViewController.swift
//  SPV
//
//  Created by dlatheron on 20/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

enum PINEntryMode {
    case pin
    case setPIN
    case confirmPIN

    var uiText: String {
        get {
            switch self {
            case .pin:
                return "Please enter your PIN"
            case .setPIN:
                return "Please enter a PIN"
            case .confirmPIN:
                return "Please re-enter the PIN"
            }
        }
    }
}

class PINEntryViewController : UIViewController {
    let defaultLockoutPeriod: TimeInterval = 5
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var pinDigits: UITextField!
    
    var pin = PIN()
    var confirmPIN = PIN()
    var entryMode: PINEntryMode = .setPIN
    var completionBlock: ((PIN) -> Void)? = nil
    
    private func hidePINEntryCursor() {
        pinDigits.tintColor = UIColor.clear
        pinDigits.textAlignment = .center
    }
    
    override func viewDidLoad() {
        hidePINEntryCursor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        listenForKeyboardAppearance()
        
        refreshUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopListeningForKeyboardAppearance()
    }
}

extension PINEntryViewController : UITextFieldDelegate {
    var activePIN: PIN {
        get {
            if entryMode == .confirmPIN {
                return confirmPIN
            } else {
                return pin
            }
        }
    }
    
    // Need to set PIN appropriately based on the mode...
    func reset() {
        pin.reset()
        confirmPIN.reset()
        
        refreshUI()
    }
    
    func refreshUI() {
        label.text = entryMode.uiText
        updatePIN()
        pinDigits.becomeFirstResponder()
    }
    
    func updatePIN() {
        pinDigits.text = activePIN.uiText
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activePIN.reset()
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if let _ = Int(string) {
            activePIN.append(string[string.startIndex])
            
            updatePIN()
            
            // TODO: Confirmation or exit???
            if activePIN.complete {
                print("PIN \(entryMode) set as \(activePIN.asString)")
                
                var complete = false
                
                switch entryMode {
                case .pin:
                    if pin == confirmPIN {
                        complete = true
                    } else {
                        self.wrongPIN(lockout: defaultLockoutPeriod)
                    }
                    
                case .setPIN:
                    entryMode = .confirmPIN
                    refreshUI()
                    
                case .confirmPIN:
                    if pin == confirmPIN {
                        complete = true
                    } else {
                        activePIN.reset()
                        entryMode = .setPIN
                        activePIN.reset()
                        self.wrongPIN()
                    }
                }
                
                if complete {
                    self.dismiss(animated: true) {
                        self.completionBlock?(self.pin)
                    }
                }
            }
            
            return false
        } else {
            return false
        }
    }
}

extension PINEntryViewController {
    func wrongPIN(lockout: TimeInterval = 0) {
        view.shake {
            self.reset()
        }
    }
}

extension PINEntryViewController {
    func listenForKeyboardAppearance() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PINEntryViewController.keyboardWillChangeFrame),
                                               name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(PINEntryViewController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide,
                                               object: nil)
    }
    
    func stopListeningForKeyboardAppearance() {
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillChangeFrame,
                                                  object: self.view.window)
        NotificationCenter.default.removeObserver(self,
                                                  name: NSNotification.Name.UIKeyboardWillHide,
                                                  object: self.view.window)
    }
    
    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if pinDigits.isFirstResponder {
                self.view.frame.origin.y = -keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
}
