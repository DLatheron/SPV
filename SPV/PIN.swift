//
//  PIN.swift
//  SPV
//
//  Created by dlatheron on 23/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class PIN {
    let presentCh: Character = "⚫︎"
    let abscentCh: Character = "⚪︎"
    let spacingCh: Character = " "
    let maxDigits = 4
    
    private var _pin: [Character] = []
    
    subscript(index: Int) -> Character? {
        get {
            return (index < _pin.count)
                ? _pin[index]
                : nil
        }
    }
    
    var asString: String {
        get {
            return String(_pin)
        }
    }
    
    var uiText: String {
        get {
            var results: [Character] = []
            
            for index in 0 ..< maxDigits {
                if index < _pin.count {
                    results.append(presentCh)
                } else {
                    results.append(abscentCh)
                }
                
                if index < (maxDigits - 1) {
                    //results.append(spacingCh)
                }
            }
            
            return String(results)
        }
    }
    
    var text: String {
        get {
            var results: [Character] = []
            
            for index in 0 ..< maxDigits {
                if index < _pin.count {
                    results.append(_pin[index])
                } else {
                    results.append(abscentCh)
                }
                
                if index < (maxDigits - 1) {
                    //results.append(spacingCh)
                }
            }
            
            return String(results)
        }
    }
    
    var complete: Bool {
        get {
            return _pin.count == maxDigits
        }
    }
    
    init() {
    }
    
    init(_ string: String) {
        // TODO: Limit characters to maxDigits...
        
        string.forEach { (ch) in
            _pin.append(ch)
        }
    }
    
    func append(_ ch: Character) {
        if !complete {
            _pin.append(ch)
        }
    }
    
    func backspace() {
        if _pin.count > 0 {
            _pin.remove(at: _pin.count - 1)
        }
    }
    
    func reset() {
        _pin = []
    }
}

extension PIN : Equatable {
    public static func ==(lhs: PIN, rhs: PIN) -> Bool{
        return lhs.text == rhs.text
    }
}
