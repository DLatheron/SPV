//
//  DownloadManager.swift
//  SPV
//
//  Created by David Latheron on 13/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class DownloadManager : DownloadManagerBase {
    static var shared = DownloadManager()
    
    // On-demand creation of the session - this is effectively a persistent object.
    var session: URLSession {
        get {
            let config = URLSessionConfiguration.background(withIdentifier: "\(Bundle.main.bundleIdentifier!).background")
            
            config.allowsCellularAccess = true
            
            // Warning: If an URLSession still exists from a previous download, it doesn't create
            // a new URLSession object but returns the existing one with the old delegate object attached!
            return URLSession(configuration: config,
                              delegate: self,
                              delegateQueue: OperationQueue())
        }
    }
    
    override init() {
        super.init()

        // Find any existing downloads associated with the session.
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            self.downloads = downloads.map { (downloadTask) in
                let remoteURL = (downloadTask.currentRequest?.url)!
                
                return Download(remoteURL: remoteURL,
                                task: downloadTask)
            }
        }
    }
    
    func download(remoteURL: URL) {
        let request = URLRequest(url: remoteURL,
                                 cachePolicy: .useProtocolCachePolicy)
        let task = session.downloadTask(with: request)
        let download = Download(remoteURL: remoteURL,
                                task: task)
        download.pause = false

        add(download: download)
    }
    
    func getURLForDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        
        return paths[0] as URL
    }
    
    func makeFileDownloadURL(downloadURL: URL) -> URL {
        let originalFilename = downloadURL.lastPathComponent
        let documentsDirectoryURL = getURLForDocumentsDirectory()
        let localFileURL = documentsDirectoryURL.appendingPathComponent(originalFilename);
        
        return localFileURL
    }
}

extension DownloadManager : URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        if let statusCode = (downloadTask.response as? HTTPURLResponse)?.statusCode {
            print("Success: \(statusCode)")
        }
        
        let remoteURL = (downloadTask.currentRequest?.url)!
        let localURL = makeFileDownloadURL(downloadURL: remoteURL)
        
        do {
            try FileManager.default.copyItem(at: location, to: localURL)
        } catch (let writeError) {
            print("Error writing file \(localURL) : \(writeError)")
        }
        
        let index = indexOfDownload(byRemoteURL: remoteURL)!
        let download = downloads[index]
        let mediaIndex = MediaManager.shared.addMedia(url: localURL)
        
        completed(download: download,
                  mediaIndex: mediaIndex)
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        // TODO: Mark the download as having errored and allow a retry???
        debugPrint("Task completed: \(task), error: \(String(describing: error))")
    }
}

extension DownloadManager : URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let remoteURL = (downloadTask.currentRequest?.url)!
            
            if let download = findDownload(byRemoteURL: remoteURL) {
                download.totalSizeInBytes = totalBytesExpectedToWrite
                download.bytesDownloaded = totalBytesWritten
                
                update(download: download)
            }
        }
    }
}
