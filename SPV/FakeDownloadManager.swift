//
//  FakeDownloadManager.swift
//  SPV
//
//  Created by dlatheron on 01/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class FakeDownloadManager {
    weak var delegate: DownloadChangedProtocol?
    
    var downloads: [Download] = [] //{
//        didSet {
//            delegate?.allDownloadsChanged(downloads: downloads)
//        }
//    }
    
    init() {
        add(download: Download(remoteURL: URL(string: "http://nowhere.co.uk/image01.jpg")!))
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: timerTick)
    }
    
    func add(download: Download) {
        downloads.append(download)
        
        delegate?.downloadChanged(download: download)
    }
    
    func update(download: Download) {
        delegate?.downloadChanged(download: download)
    }
    
    func completed(download: Download) {
        delegate?.downloadCompleted(download: download)
    }
    
    func timerTick(timer: Timer) {
        if downloads.count == 0 {
            add(download: Download(remoteURL: URL(string: "http://nowhere.co.uk/image01.jpg")!))
        } else {
            downloads.forEach { (download) in
                if download.totalSizeInBytes == 0 {
                    download.totalSizeInBytes = 1_000
                    delegate?.downloadChanged(download: download)
                } else if (download.bytesDownloaded < download.totalSizeInBytes) {
                    if download.pause == true {
                        download.bytesDownloaded += 50
                        delegate?.downloadChanged(download: download)
                    }
                } else if (download.bytesDownloaded >= download.totalSizeInBytes) {
                    downloads.remove(at: downloads.index(of: download)!)
                    delegate?.downloadCompleted(download: download)
                }
            }
        }
    }
}
