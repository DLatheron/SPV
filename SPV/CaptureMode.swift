//
//  CameraMode.swift
//  SPV
//
//  Created by dlatheron on 17/03/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import AVFoundation

enum CaptureMode {
    case photo
    case video
    
    var imageName: String {
        get {
            switch self {
            case .photo: return "cameraInv.png"
            case .video: return "video.png"
            }
        }
    }
    
    mutating func next() -> CaptureMode {
        switch self {
        case .photo:
            self = .video
        case .video:
            self = .photo
        }
        
        return self
    }
}
