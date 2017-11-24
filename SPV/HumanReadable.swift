//
//  HumanReadable.swift
//  SPV
//
//  Created by dlatheron on 29/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class HumanReadable {
    
    enum BytesUnits: Int {
        case bytes = 0
        case siBytes = 1
    }
    
    enum BPSUnits: Int {
        case bitsPerSecond = 0
        case siBytesPerSecond = 1
        case bytesPerSecond = 2
    }
    
    static private let bytesUnits = [
        (
            scaler: 1024.0,
            units: [ "B", "KiB", "MiB", "GiB", "TiB", "PiB", "EiB" ]
        ),
        (
            scaler: 1000.0,
            units: [ "B", "kB", "MB", "GB", "TB", "PB", "EB" ]
        )
    ]
    
    static private let bpsUnits = [
        (
            multipler: 1.0 / 8.0,
            scaler: 1000.0,
            units: [ "bps", "Kbps",  "Mbps",  "Gbps",  "Tbps",  "Pbps",  "Ebps" ]
        ),
        (
            multipler: 1.0,
            scaler: 1000.0,
            units: [ "B/s", "KB/s",  "MB/s",  "GB/s",  "TB/s",  "PB/s",  "EB/s" ]
        ),
        (
            multipler: 1.0,
            scaler: 1024.0,
            units: [ "B/s", "KiB/s", "MiB/s", "GiB/s", "TiB/s", "PiB/s", "EiB/s" ]
        )
    ]
    
    class func bytes(bytes: Int64?,
                     units: BytesUnits = .bytes,
                     space: Bool = false) -> String {
        if let bytes = bytes {
            let transferunits = bytesUnits[units.rawValue]
            let spacing = space ? " " : ""
            let scaler = transferunits.scaler
            let units = transferunits.units
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            
            if (bytes < Int64(scaler)) {
                let formattedNumber = numberFormatter.string(from: NSNumber(value: bytes))
                return formattedNumber! + spacing + units[0]
            } else {
                let exp = Int(log(Double(bytes)) / log(scaler))
                let suffix = units[exp]
                
                numberFormatter.minimumFractionDigits = 1
                numberFormatter.maximumFractionDigits = 1
                
                let formattedNumber = numberFormatter.string(from: NSNumber(value: Double(bytes) / pow(scaler, Double(exp))))
                
                return formattedNumber! + spacing + suffix
            }
        } else {
            return "-"
        }
    }
    
    class func duration(duration: TimeInterval?) -> String {
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

    
    class func bps(bytesPerSecond: Double?,
                   units: BPSUnits = .bitsPerSecond,
                   space: Bool = false) -> String {
        if var bytesPerSecond = bytesPerSecond {
            let transferUnit = bpsUnits[units.rawValue]
            
            bytesPerSecond = bytesPerSecond * transferUnit.multipler
            
            let spacing = space ? " " : ""
            let scaler = transferUnit.scaler
            let units = transferUnit.units
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = NumberFormatter.Style.decimal
            numberFormatter.minimumFractionDigits = 1
            numberFormatter.maximumFractionDigits = 1
            
            if (bytesPerSecond < scaler) {
                let formattedNumber = numberFormatter.string(from: NSNumber(value: bytesPerSecond))
                
                return formattedNumber! + spacing + units[0]
            } else {
                let exp = Int(log(bytesPerSecond) / log(scaler))
                let suffix = units[exp]
                
                let formattedNumber = numberFormatter.string(from: NSNumber(value: Double(bytesPerSecond) / pow(scaler, Double(exp))))
                
                return formattedNumber! + spacing + suffix
            }
        } else {
            return "-"
        }
    }    
}
