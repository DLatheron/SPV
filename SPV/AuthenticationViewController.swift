//
//  AuthenticationViewController.swift
//  SPV
//
//  Created by dlatheron on 29/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class AuthenticationViewController : UIViewController {
    @IBOutlet var pinDigits: [PINDigit]!
    @IBOutlet var pinButtons: [PINButton]!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    var authenticationService: AuthenticationService!
    var entryMode: PINEntryMode = PINEntryMode.pin
    
    let retryTimes = [ 0, 3, 9, 18, 81 ]
    var pinItems: [KeychainPasswordItem] = []
    
    var completionBlock: ((Bool, PIN?) -> Void)? = nil
    var canCancel: Bool = false
    var canUseBiometry: Bool = true
    var authenticationDelegate: AuthenticationDelegate? = nil

    fileprivate let pin = PIN()
    fileprivate var expectedPIN = PIN("1111")
    fileprivate var attempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinDigits.sort { $0.tag > $1.tag }
        
        if canUseBiometry && entryMode == .pin && authenticationService.hasBiometry {
            pinButtons[9].configureForImage(named: authenticationService.iconName)
        }
        pinButtons[11].configureForImage(named: "backspace")
        
        if UIScreen.main.bounds.height <= 568 {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        
        if !canCancel {
            navigationItem.rightBarButtonItem = nil
        }
        
        setTitle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func setTitle() {
        switch entryMode {
        case .pin:
            self.title = NSLocalizedString("Please enter your PIN", comment: "Title for PIN view controller")
        case .setPIN:
            self.title = NSLocalizedString("Please type a new PIN", comment: "Title for setting a new PIN")
        case .confirmPIN:
            self.title = NSLocalizedString("Please confirm your PIN}", comment: "Title for confirming a new PIN")
        }
    }
}

extension AuthenticationViewController : PINButtonDelegate {
    func refreshPIN() {
        for pinDigit in pinDigits {
            let index = pinDigit.tag            
            pinDigit.filled = pin[index] != nil
        }
    }
    
    func clearPIN() {
        pin.reset()
        refreshPIN()
    }
    
    func pressed(character: String) {
        print("\(character) was pressed")
        
        if character == "#" {
            pin.backspace()
            refreshPIN()
        } else if character == "*" {
            if authenticationService.hasBiometry {
                performBiometricAuthentication()
            }
        } else {
            pin.append(character.first!)
            refreshPIN()
            
            if pin.complete {
                switch entryMode {
                case .pin:
                    performPINAuthentication()
                case .setPIN:
                    if let confirmVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthenticationViewController") as? AuthenticationViewController {
                        confirmVC.entryMode = .confirmPIN
                        confirmVC.expectedPIN = pin
                        confirmVC.completionBlock = { success, pin in
                            if success {
                                self.completionBlock?(true, pin)
                            } else {
                                self.navigationController?.popViewController(animated: true)
                                self.clearPIN()
                            }
                        }
                        navigationController?.pushViewController(confirmVC,
                                                                 animated: true)
                    }
                case .confirmPIN:
                    performPINVerification()
                }
            }
        }
    }
}

extension AuthenticationViewController {
    @IBAction func cancel(_ sender: Any) {
        completionBlock?(false, nil)
    }
}

extension AuthenticationViewController {
    var lockoutTimeInSeconds: Int {
        get {
            return attempts < retryTimes.count
                ? retryTimes[attempts]
                : retryTimes.last!
        }
    }
    
    func authenticationFailed(reason: String,
                              increaseAttempts: Bool,
                              completionBlock: @escaping () -> Void) {
        view.shake() {
            _ = TimedAlertController(reason: reason,
                                     for: self.lockoutTimeInSeconds,
                                     viewController: self,
                                     completionBlock: completionBlock)
            if increaseAttempts {
                self.attempts += 1
            }
        }
    }
    
    func authenticationSucceeded() {
        print("Authentication Succeeded")
        completionBlock?(true, pin)
    }

    func performPINAuthentication() {
        if authenticationDelegate?.performPINAuthentication(pin: pin)
            ?? false {
            authenticationSucceeded()
        } else {
            authenticationFailed(reason: "Incorrect PIN",
                                 increaseAttempts: true) {
                self.clearPIN()
            }
        }
    }
}

extension AuthenticationViewController {
    func verificationFailed() {
        view.shake() {
            _ = TimedAlertController(reason: "PINs do not match",
                                     for: 0,
                                     viewController: self)
            {
                self.completionBlock?(false, nil)
            }
        }
    }
    
    func verificationSucceeded() {
        print("Verification Succeeded")
        completionBlock?(true, pin)
    }
    
    func performPINVerification() {
        if pin == expectedPIN {
            verificationSucceeded()
        } else {
            verificationFailed()
        }
    }
}

extension AuthenticationViewController {
    func performBiometricAuthentication() {
        authenticationDelegate?.performBiometricAuthentication()
            { success, reason, increaseAttempts in
                if success {
                    self.authenticationSucceeded()
                } else {
                    self.authenticationFailed(reason: reason ?? "Biometric Failure",
                                              increaseAttempts: increaseAttempts) {
                        self.clearPIN()
                    }
                }
        }
    }
}
