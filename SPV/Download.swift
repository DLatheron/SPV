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
                return Double(bytesRemaining) / bps
            } else {
                return nil
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
    
    class func humanReadableBytes(bytes: Int64?,
                                  si: Bool = false,
                                  space: Bool = false) -> String {
        if let bytes = bytes {
            let spacing = space ? " " : ""
            let unit = si ? 1000 : 1024

            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            
            if (bytes < Int64(unit)) {
                let formattedNumber = numberFormatter.string(from: NSNumber(value: bytes))
                return formattedNumber! + spacing + "B";
            } else {
                let chars = si ? [ "kB", "MB", "GB", "TB", "PB", "EB" ] : [ "KiB", "MiB", "GiB", "TiB", "PiB", "EiB" ]
                let exp = Int(log(Double(bytes)) / log(Double(unit)));
                let suffix = chars[exp - 1];

                numberFormatter.minimumFractionDigits = 1
                numberFormatter.maximumFractionDigits = 1
     
                let formattedNumber = numberFormatter.string(from: NSNumber(value: Double(bytes) / pow(Double(unit), Double(exp))))
                
                return formattedNumber! + spacing + suffix;
            }
        } else {
            return "-"
        }
    }
    
    class func humanReadableDuration(duration: TimeInterval?) -> String {
        if let duration = duration {
            let hours = Int(duration) / (60 * 60)
            let minutes = Int(duration) / 60 % 60
            let seconds = Int(duration) % 60

            switch duration {
            case _ where duration <= 1.0:
                return "< 1 sec"
            case _ where duration < 60.0:
                return "\(seconds) secs"
            case _ where duration < (60.0 * 60.0):
                return "\(minutes):\(seconds)"
            default:
                return "\(hours):\(minutes):\(seconds)"
            }
        } else {
            return "-"
        }
    }
    
    enum BPSUnits: Int {
        case bitsPerSecond = 0
        case siBytesPerSecond = 1
        case bytesPerSecond = 2
    }
    
    class func humanReadableBPS(bytesPerSecond: Double?,
                                units: BPSUnits = .bitsPerSecond,
                                space: Bool = false) -> String {
        let allTransferUnits = [
            ( scaler: 1000.0, units: [ "bps", "Kbps",  "Mbps",  "Gbps",  "Tbps",  "Pbps",  "Ebps" ]),
            ( scaler: 8000.0, units: [ "B/s", "KB/s",  "MB/s",  "GB/s",  "TB/s",  "PB/s",  "EB/s" ]),
            ( scaler: 8192.0, units: [ "B/s", "KiBps", "MiBps", "GiBps", "TiBps", "PiBps", "EiB"  ])
        ]
        
        let transferUnit = allTransferUnits[units.rawValue]
        
        if let bytesPerSecond = bytesPerSecond {
            let spacing = space ? " " : ""
            let scaler = transferUnit.scaler
            let units = transferUnit.units
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.minimumFractionDigits = 1
            numberFormatter.maximumFractionDigits = 1
            
            if (bytesPerSecond < scaler) {
                let formattedNumber = numberFormatter.string(from: NSNumber(value: bytesPerSecond))
                return formattedNumber! + spacing + units[0];
            } else {
                let exp = Int(log(bytesPerSecond) / log(scaler));
                let suffix = units[exp];
                
                let formattedNumber = numberFormatter.string(from: NSNumber(value: Double(bytesPerSecond) / pow(scaler, Double(exp))))
                
                return formattedNumber! + spacing + suffix;
            }
        } else {
            return "-"
        }
    }
}
