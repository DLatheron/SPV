//
//  AVCaptureDevice.DiscoverySession.swift
//  SPV
//
//  Created by dlatheron on 18/03/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import AVFoundation

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions: [AVCaptureDevice.Position] = []
        
        for device in devices {
            if !uniqueDevicePositions.contains(device.position) {
                uniqueDevicePositions.append(device.position)
            }
        }
        
        return uniqueDevicePositions.count
    }
}
