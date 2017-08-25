//
//  Download.swift
//  SPV
//
//  Created by David Latheron on 24/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

extension Comparable {
    func clamp(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

class Download : NSObject {
    internal(set) var remoteURL: URL
    internal(set) var name: String
    
    var totalSizeInBytes: Int64 = 0
    var bytesDownloaded: Int64 = 0
    
    var totalSizeInBytesHumanReadable: String {
        get {
            return "\(totalSizeInBytes) bytes"
        }
    }
    
    var progress: Double {
        get {
            if (totalSizeInBytes > 0) {
                let progress = Double(bytesDownloaded) / Double(totalSizeInBytes)
                return progress.clamp(to: 0.0 ... 1.0)
            } else {
                return 0.0
            }
        }
    }
    
    var percentage: Double {
        get {
            return progress * 100.0
        }
    }
    
    var complete: Bool {
        get {
            if (totalSizeInBytes > 0) {
                return bytesDownloaded >= totalSizeInBytes
            } else {
                return false
            }
        }
    }
    
    var bytesRemaining: Int64 {
        get {
            return totalSizeInBytes - bytesDownloaded
        }
    }
    
    internal(set) var startTime: Date = Date()
    internal(set) var endTime: Date? = nil
    
    var durationInSeconds: TimeInterval? {
        get {
            if !pause{
                if let endTime = endTime {
                    return endTime.timeIntervalSince(startTime)
                } else {
                    return -startTime.timeIntervalSinceNow
                }
            } else {
                return nil
            }
        }
    }
    
    var durationHumanReadable: String {
        get {
            if let durationInSeconds = durationInSeconds {
                return "\(durationInSeconds)s"
            } else {
                return "-"
            }
        }
    }
    
    var downloadSpeedInBPS: Double? {
        get {
            if let duration = durationInSeconds, duration > 0 {
                return Double(bytesDownloaded) / duration
            } else {
                return nil
            }
        }
    }
    
    var timeRemainingInSeconds: TimeInterval? {
        get {
            // Calculate how long it takes to download a byte and scale up?
            if let bps = downloadSpeedInBPS {
                return Double(bytesRemaining) * bps
            } else {
                return nil
            }
        }
    }
    
    var timeRemainingHumanReadable: String {
        get {
            if let timeRemainingInSeconds = timeRemainingInSeconds {
                return "\(timeRemainingInSeconds)s"
            } else {
                return "-"
            }
        }
    }
    
    var downloadSpeedHumanReadable: String {
        get {
            if let downloadSpeedInBPS = downloadSpeedInBPS {
                return "\(downloadSpeedInBPS)bps"
            } else {
                return "-"
            }
        }
    }
    
    var pause: Bool = true {
        didSet {
            if pause {
                // Pausing.
            } else {
                // Resuming.
                startTime = Date()
            }
        }
    }

    var index: Int? = nil
    
    init(remoteURL: URL) {
        self.remoteURL = remoteURL
        self.name = remoteURL.lastPathComponent
    }
}
