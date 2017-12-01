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
    func performBiometricAuthentication(completionBlock: @escaping (Bool, String?) -> Void)
}

class AuthenticationService {
    let context = LAContext()
    
    var biometryType: String {
        get {
            switch context.biometryType {
            case .typeTouchID:
                return "Touch ID"
            case .typeFaceID:
                return "Face ID"
            default :
                return "Unknown"
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
    
    func registerPIN(pin: PIN) {
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
    
    func performBiometricAuthentication(completionBlock: @escaping (Bool, String?) -> Void) {
        guard context.canEvaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            error: nil)
            else {
            return completionBlock(false, "\(biometryType) not available")
        }
        
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Logging in with \(biometryType)")
        {
            (success, evaluateError) in
            if success {
                DispatchQueue.main.async {
                    completionBlock(true, nil)
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
                default:
                    message = "Touch ID may not be configured"
                }
                
                DispatchQueue.main.async {
                    completionBlock(false, message)
                }
            }
        }
    }
}
