//
//  DownloadDetails.swift
//  SPV
//
//  Created by David Latheron on 24/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class DownloadDetails : NSObject {
    var remoteURL: URL
    var name: String
    var size: Int64
    var timeRemaining: String
    var downloadSpeed: String
    dynamic var percentage: Double
    var isPaused: Bool
    var time: String
    var index: Int?
    
    init(remoteURL: URL) {
        self.remoteURL = remoteURL
        self.name = remoteURL.lastPathComponent
        self.size = 0
        self.timeRemaining = "-"
        self.downloadSpeed = "-"
        self.percentage = 0.0
        self.isPaused = false
        self.time = ""
        self.index = nil
    }
    
    func downloadComplete(atIndex: Int) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        
        self.time = dateFormatter.string(from: Date())
        self.index = atIndex
        self.percentage = 1.0
        self.downloadSpeed = "-"
        self.timeRemaining = "-"
    }
}
