//
//  FakeDownloadManager.swift
//  SPV
//
//  Created by dlatheron on 01/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class FakeDownloadManager {
    static var shared = FakeDownloadManager()
    
    weak var delegate: DownloadChangedProtocol?
    
    var downloads: [Download] = []
    var completed: [Download] = []
    
    init() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: timerTick)
    }
    
    func clearCompletedDownloads() {
        completed = []
    }
    
    func add(download: Download) {
        download.pause = false
        downloads.insert(download, at: 0)
        
        print("New \(download.name) started")
        delegate?.downloadChanged(download: download)
    }
    
    func update(download: Download) {
        print("\(download.name) progress \(download.percentage)%")
        delegate?.downloadChanged(download: download)
    }
    
    func completed(download: Download) {
        download.index = 0
        
        downloads.remove(at: (downloads.index(of: download)!))
        completed.insert(download, at: 0)
        
        print("\(download.name) completed")
        delegate?.downloadCompleted(download: download)
    }
    
    func timerTick(timer: Timer) {
        if downloads.count == 0 {
            let interval = timer.fireDate.timeIntervalSince1970;
            
            add(download: Download(remoteURL: URL(string: "http://nowhere.co.uk/image-\(interval).jpg")!))
        } else {
            downloads.forEach { (download) in
                if download.totalSizeInBytes == 0 {
                    download.totalSizeInBytes = 1_000
                    update(download: download)
                } else if (download.bytesDownloaded < download.totalSizeInBytes) {
                    if !download.pause {
                        download.bytesDownloaded += 50
                        update(download: download)
                    }
                } else if (download.bytesDownloaded >= download.totalSizeInBytes) {
                    completed(download: download)
                }
            }
        }
    }
}
