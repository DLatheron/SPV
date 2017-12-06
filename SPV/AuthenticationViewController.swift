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
    
    let retryTimes = [ 0, 3, 9, 18, 81 ]
    var pinItems: [KeychainPasswordItem] = []
    
    var completionBlock: ((Bool) -> Void)? = nil
    var canCancel: Bool = false
    var authenticationDelegate: AuthenticationDelegate? = nil

    fileprivate let pin = PIN()
    fileprivate let expectedPIN = PIN("1111")
    fileprivate var attempts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinDigits.sort { $0.tag > $1.tag }
        
        // TODO: Move.
        authenticationService = AuthenticationService()
        authenticationService.registerPIN(pin: expectedPIN)
        authenticationDelegate = authenticationService
        
        if authenticationService.hasBiometry {
            pinButtons[9].configureForImage(named: authenticationService.iconName)
        }
        pinButtons[11].configureForImage(named: "backspace")
        
        if UIScreen.main.bounds.height <= 568 {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
        
        if !canCancel {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
                performPINAuthentication()
            }
        }
    }
}

extension AuthenticationViewController {
    @IBAction func cancel(_ sender: Any) {
        completionBlock?(false)
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
        completionBlock?(true)
    }
}

extension AuthenticationViewController {
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
