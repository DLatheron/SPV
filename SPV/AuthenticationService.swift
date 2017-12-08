//
//  Authentication.swift
//  SPV
//
//  Created by dlatheron on 01/12/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import LocalAuthentication

struct KeychainConfiguration {
    static let serviceName = "SPV"
    static let defaultAccountName = "Default"
    static let accessGroup: String? = nil
}

protocol AuthenticationDelegate {
    func performPINAuthentication(pin: PIN) -> Bool
    func performBiometricAuthentication(completionBlock: @escaping (Bool, String?, Bool) -> Void)
}

class AuthenticationService {
    static var shared = AuthenticationService()
    
    let context = LAContext()
    
    var hasBiometry: Bool {
        get {
            return biometryType != "Unknown"
        }
    }
    
    var biometryType: String {
        get {
            switch context.biometryType {
            case .touchID:
                return "Touch ID"
            case .faceID:
                return "Face ID"
            default:
                return "Unknown"
            }
        }
    }
    
    var iconName: String {
        get {
            switch context.biometryType {
            case .touchID:
                return "touchID"
            case .faceID:
                return "faceID"
            default:
                return "faceID"
            }
        }
    }
    
    var pinHasBeenSet: Bool {
        get {
            do {
                let passwordItem = keychainPasswordItem
                let keychainPIN = try passwordItem.readPassword()
                
                return PIN(keychainPIN).complete
            }
            catch {
                // TODO: Corrupt reading of keychain - fail safe and deny access.
                print("Error reading PIN from keychain - \(error)")
                return true
            }
        }
    }
    
    fileprivate var keychainPasswordItem: KeychainPasswordItem {
        get {
            return KeychainPasswordItem(
                service: KeychainConfiguration.serviceName,
                account: KeychainConfiguration.defaultAccountName,
                accessGroup: KeychainConfiguration.accessGroup
            )
        }
    }
    
    func register(pin: PIN) {
        guard pin.complete
            else {
            return
        }
        
        do {
            let passwordItem = keychainPasswordItem
        
            try passwordItem.savePassword(pin.asString)
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
    
    func clear() {
        do {
            let passwordItem = keychainPasswordItem
            
            try passwordItem.savePassword("")
        } catch {
            fatalError("Error updating keychain - \(error)")
        }
    }
}

extension AuthenticationService : AuthenticationDelegate {
    func performPINAuthentication(pin: PIN) -> Bool {
        guard pin.complete
            else {
            return false
        }
        
        do {
            let passwordItem = keychainPasswordItem
            let keychainPIN = try passwordItem.readPassword()
            
            return pin.asString == keychainPIN
        }
        catch {
            fatalError("Error reading PIN from keychain - \(error)")
        }
    }
    
    func performBiometricAuthentication(completionBlock: @escaping (Bool, String?, Bool) -> Void) {
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: nil)
            else {
            return completionBlock(false, "\(biometryType) not available", false)
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Logging in with \(biometryType)")
        {
            (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completionBlock(true, nil, true)
                }
            } else {
                let message: String
                
                switch evaluateError {
                case LAError.authenticationFailed?:
                    message = "There was a problem verifying your identity"
                case LAError.userCancel?:
                    message = "You pressed cancel"
                case LAError.userFallback?:
                    message = "You pressed password"
                case LAError.biometryNotEnrolled?:
                    message = "\(self.biometryType) is not configured"
                case LAError.biometryLockout?:
                    message = "\(self.biometryType) is locked out"
                case LAError.biometryNotAvailable?:
                    message = "\(self.biometryType) is not available"
                default:
                    message = "\(self.biometryType) may not be configured"
                }
                
                DispatchQueue.main.async {
                    completionBlock(false, message, false)
                }
            }
        }
    }
}
