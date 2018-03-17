//
//  FlashMode.swift
//  SPV
//
//  Created by dlatheron on 17/03/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import AVFoundation

enum FlashMode {
    case flashAuto
    case flashOn
    case flashOff
    
    var deviceFlashMode: AVCaptureDevice.FlashMode {
        get {
            switch self {
            case .flashAuto: return AVCaptureDevice.FlashMode.auto
            case .flashOn: return AVCaptureDevice.FlashMode.on
            case .flashOff: return AVCaptureDevice.FlashMode.off
            }
        }
    }
    
    mutating func next() -> FlashMode {
        switch self {
        case .flashAuto:
            self = .flashOn
        case .flashOn:
            self = .flashOff
        case .flashOff:
            self = .flashAuto
        }
        
        return self
    }
}
