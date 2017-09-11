//
//  DownloadManagerBase.swift
//  SPV
//
//  Created by David Latheron on 02/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation


protocol DownloadChangedProtocol: class {
    func changed(download: Download)
    func deleted(download: Download)
    func completed(download: Download)
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
    
    func delete(download: Download) {
        if let index = downloads.index(of: download) {
            downloads.remove(at: index)
        } else if let index = completed.index(of: download) {
            completed.remove(at: index)
        }
        
        download.task?.cancel()
        print("\(download.name) deleted")
        delegate?.deleted(download: download)
    }
    
    func add(download: Download) {
        downloads.insert(download, at: 0)
        
        download.resume()
        print("New \(download.name) started")
        delegate?.changed(download: download)
    }
    
    func update(download: Download) {
        print("\(download.name) progress \(download.percentage)%")
        delegate?.changed(download: download)
    }
    
    func completed(download: Download,
                   media: Media) {
        download.completed(withMedia: media)
        
        downloads.remove(at: (downloads.index(of: download)!))
        completed.insert(download, at: 0)
        
        print("\(download.name) completed")
        delegate?.completed(download: download)
    }
}
