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
    internal var task: URLSessionDownloadTask?

    internal(set) var startTime: Date? = nil
    internal var timeAccumulated: TimeInterval = 0.0
    internal var bytesSinceResume: Int64 = 0

    internal(set) var totalSizeInBytes: Int64 = 0
    internal(set) var index: Int? = nil
    internal(set) var isPaused: Bool = true
    
    internal(set) var bytesDownloaded: Int64 = 0 {
        didSet {
            let bytesDelta = bytesDownloaded - oldValue
            bytesSinceResume += bytesDelta
        }
    }
    
    var progress: Double {
        get {
            if totalSizeInBytes > 0 {
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
            if index != nil {
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

    init(remoteURL: URL,
         task: URLSessionDownloadTask? = nil,
         at date: Date = Date()) {
        self.remoteURL = remoteURL
        self.name = remoteURL.lastPathComponent
        self.task = task
    }
    
    func completed(withMediaIndex index: Int,
                   at date: Date = Date()) {
        self.index = index
        
        accumulateTimeSinceLastResumed(date: date)
    }
    
    func pause(at date: Date = Date()) {
        if !isPaused {
            task?.suspend()
            isPaused = true

            accumulateTimeSinceLastResumed(date: date)
        }
    }
    
    func resume(at date: Date = Date()) {
        if isPaused {
            startTime = date
            self.bytesSinceResume = 0
            
            task?.resume()
            isPaused = false
        }
    }
    
    func durationInSeconds(at date: Date = Date()) -> TimeInterval {
        if isPaused || complete {
            return timeAccumulated
        } else {
            return timeAccumulated + date.timeIntervalSince(self.startTime!)
        }
    }
    
    func downloadSpeedInBPS(at date: Date = Date()) -> Double? {
        let duration = durationInSeconds(at: date)
        
        if !isPaused && duration > 0.0  {
            return Double(bytesSinceResume) / duration
        } else {
            return nil
        }
    }
    
    func timeRemainingInSeconds(at date: Date = Date()) -> TimeInterval? {
        if let bps = downloadSpeedInBPS(at: date), bps > 0.0, !isPaused {
            return Double(bytesRemaining) / bps
        } else {
            return nil
        }
    }
    
    private func accumulateTimeSinceLastResumed(date: Date) {
        self.timeAccumulated += date.timeIntervalSince(self.startTime!)
        self.startTime = date
    }
}
