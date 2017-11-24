//
//  FakeDownloadManager.swift
//  SPV
//
//  Created by dlatheron on 01/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class FakeDownloadManager : DownloadManagerBase {
    static var shared = FakeDownloadManager()
    
    override init() {
        super.init()
        
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: timerTick)
    }

    func timerTick(timer: Timer) {
        if downloads.count == 0 {
            let interval = timer.fireDate.timeIntervalSince1970
            
            add(download: Download(remoteURL: URL(string: "http://nowhere.co.uk/image-\(interval).jpg")!))
        } else {
            downloads.forEach { (download) in
                if download.totalSizeInBytes == 0 {
                    download.totalSizeInBytes = 1_000
                    update(download: download)
                } else if (download.bytesDownloaded < download.totalSizeInBytes) {
                    if !download.isPaused {
                        download.bytesDownloaded += 5
                        update(download: download)
                    }
                } else if (download.bytesDownloaded >=
                    download.totalSizeInBytes) {
                    let fakeMedia = MediaManager.shared.media[0]
                    completed(download: download,
                              media: fakeMedia)
                }
            }
        }
    }
}
