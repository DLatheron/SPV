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
    
    var completionBlock: (() -> Void)? = nil
    
    let pin = PIN()
    let expectedPIN = PIN()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinDigits.sort { $0.tag > $1.tag }
        
        if UIScreen.main.bounds.height <= 568 {
            navigationController?.navigationBar.prefersLargeTitles = false
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
    
    func pressed(character: String) {
        print("\(character) was pressed")
        
        if character == "#" {
            pin.backspace()
            refreshPIN()
        } else if character == "*" {
            performBiometricAuthentication()
        } else {
            pin.append(character.first!)
            refreshPIN()
            
            if pin.complete {
                if pin == expectedPIN {
                    completionBlock?()
                }
            }
        }
    }
}

extension AuthenticationViewController {
    func performBiometricAuthentication() {
        
    }
}
