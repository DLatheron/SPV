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
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var topToolbarView: UIToolbar!
    @IBOutlet weak var contentViewCentreYConstraint: NSLayoutConstraint!
    
    var pin = PIN()
    var confirmPIN = PIN()
    var expectedPINHash: String = ""
    
    var entryMode: PINEntryMode = .setPIN
    var completionBlock: ((PIN) -> Void)? = nil
    var attemptsRemaining = 3
    var keyboardHeight: CGFloat = 0
    
    private func hidePINEntryCursor() {
        pinDigits.tintColor = UIColor.clear
        pinDigits.textAlignment = .center
    }
    
    override func viewDidLoad() {
        hidePINEntryCursor()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if entryMode == .pin {
            attemptsRemaining = 3
        } else {
            attemptsRemaining = 0
        }
        
        ensureCentred()
        
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
        print("Range: \(range) string: \(string)")
        if string.isEmpty {
            activePIN.backspace()
            
            updatePIN()
        } else if let _ = Int(string) {
            if !activePIN.complete {
                activePIN.append(string[string.startIndex])
                
                updatePIN()
                
                if activePIN.complete {
                    print("PIN \(entryMode) set as \(activePIN.asString)")
                    
                    pinDigits.resignFirstResponder()
                    
                    switch entryMode {
                    case .pin:
                        if pin.verifyPIN(hash: expectedPINHash) {
                            completeTransition()
                        } else {
                            wrongPIN(lockout: defaultLockoutPeriod)
                        }
                        
                    case .setPIN:
                        confirmTransition()
                        
                    case .confirmPIN:
                        if pin == confirmPIN {
                            completeTransition()
                        } else {
                            resetTransition()
                        }
                    }
                }
            }
        }
        
        return false
    }
}

extension PINEntryViewController {
    func confirmTransition() {
        Dispatch.delay(callOf: {
            self.entryMode = .confirmPIN
            self.refreshUI()
        },
                       for: 0.6)
    }
    
    func resetTransition() {
        Dispatch.delay(callOf: {
            self.activePIN.reset()
            self.entryMode = .setPIN
            self.activePIN.reset()
            self.wrongPIN()
        },
                       for: 0.6)
    }
        
    func completeTransition() {
        Dispatch.delay(callOf: {
            self.dismiss(animated: true) {
                self.completionBlock?(self.pin)
            }
        },
                       for: 0.6)
    }
    
    func refreshErrorText() {
        if entryMode == .pin {
            if attemptsRemaining > 1 {
                errorLabel.text = "Incorrect PIN\n\(attemptsRemaining) attempts remaining"
            } else if attemptsRemaining == 1 {
                errorLabel.text = "Incorrect PIN\n1 attempt remaining"
            } else {
                errorLabel.text = "Incorrect PIN\nLocked Out"
            }
        } else {
            errorLabel.text = "PINs do not match\nPlease try again"
        }
    }
    
    func wrongPIN(lockout: TimeInterval = 2.0) {
        self.view.isUserInteractionEnabled = false
        
        attemptsRemaining -= 1
        errorView.alpha = 0
        errorView.isHidden = false
        
        let noAttemptsLeft = attemptsRemaining == 0
        
        refreshErrorText()
        
        UIView.animate(withDuration: 0.3,
                       animations: {
            self.view.shake()
            self.errorView.alpha = 1
        }, completion: { (completed) in
            if completed {
                Dispatch.delay(callOf: {
                    UIView.animate(withDuration: 0.3,
                                   animations: {
                        self.errorView.alpha = 0
                    }, completion: { (completed) in
                        self.reset()
                        
                        if (noAttemptsLeft) {
                            self.dismiss(animated: true,
                                         completion: nil)
                        } else {
                            self.view.isUserInteractionEnabled = true
                        }
                    })
                },
                               for: lockout)
            }
        })
    }
    
    @IBAction func cancel(_ sender: Any) {
        pinDigits.resignFirstResponder()
        
        self.dismiss(animated: true,
                     completion: nil)
    }
}

extension PINEntryViewController {
    func ensureCentred() {
        let parentViewHeight = view.bounds.size.height - keyboardHeight
        let parentViewHeightNotIncKeyboard = view.bounds.size.height
        let topToolBarBottomY = (topToolbarView.frame.origin.y + topToolbarView.frame.size.height)
        
        contentViewCentreYConstraint.constant =  ((parentViewHeight - parentViewHeightNotIncKeyboard) / 2) + topToolBarBottomY
        
        self.view.setNeedsUpdateConstraints()
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
    
        print("Top View Constraint: \(contentViewCentreYConstraint.constant)")
    }
    
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
        keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        print("Keyboard Height: \(keyboardHeight)")
        ensureCentred()
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
//            if pinDigits.isFirstResponder {
//                self.view.frame.origin.y = -keyboardSize.height
//            }
//        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        keyboardHeight = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
        print("Keyboard Height: \(keyboardHeight)")
        ensureCentred()
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//            if self.view.frame.origin.y != 0 {
//                self.view.frame.origin.y += keyboardSize.height
//            }
//        }
    }
}
