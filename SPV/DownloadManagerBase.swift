//
//  DownloadManagerBase.swift
//  SPV
//
//  Created by David Latheron on 02/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation


protocol DownloadChangedProtocol: class {
    func downloadChanged(download: Download)
    func downloadCompleted(download: Download)
}

class DownloadManagerBase : NSObject {
    weak var delegate: DownloadChangedProtocol?
    
    var downloads: [Download] = []
    var completed: [Download] = []
    
    func findDownload(byRemoteURL remoteURL: URL) -> Download? {
        for download in self.downloads {
            if (download.remoteURL == remoteURL) {
                return download
            }
        }
        
        return nil
    }
    
    func indexOfDownload(byRemoteURL remoteURL: URL) -> Int? {
        for (index, download) in downloads.enumerated() {
            if download.remoteURL == remoteURL {
                return index
            }
        }
        
        return nil
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
    
    func completed(download: Download,
                   mediaIndex: Int) {
        download.index = mediaIndex
        
        downloads.remove(at: (downloads.index(of: download)!))
        completed.insert(download, at: 0)
        
        print("\(download.name) completed")
        delegate?.downloadCompleted(download: download)
    }
}
