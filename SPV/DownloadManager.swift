//
//  DownloadManager.swift
//  SPV
//
//  Created by David Latheron on 13/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol DownloadChangedProtocol: class {
    func downloadChanged(download: Download)
    func downloadCompleted(download: Download)
}

class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    static var shared = DownloadManager()
    
    weak var delegate: DownloadChangedProtocol?
    
    var downloads: [Download] = [];
    var completed: [Download] = [];
    
    override init() {
        super.init()

        initExistingDownloads()
    }
    
    func clearCompletedDownloads() {
        completed = []
    }
    
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
    
    func download(remoteURL: URL,
                  to localURL: URL,
                  completion: @escaping () -> ()) {
        let request = URLRequest(url: remoteURL,
                                 cachePolicy: .useProtocolCachePolicy)
        let download = Download(remoteURL: remoteURL)
        
        self.downloads.append(download)
        
        // We have added a new item into the list, so we need to refresh the table
        // 
        
        let task = session.downloadTask(with: request)
        task.resume()
        download.pause = false
    }
    
    func initExistingDownloads() {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            self.downloads = downloads.map { (download) in
                let remoteURL = (download.currentRequest?.url)!
            
                return Download(remoteURL: remoteURL)
            }
        }
    }
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let remoteURL = (downloadTask.currentRequest?.url)!
            
            if let download = getDetails(fromRemoteURL: remoteURL) {
                download.totalSizeInBytes = totalBytesExpectedToWrite
                download.bytesDownloaded = totalBytesWritten
            }
            
            debugPrint("Downloaded \(totalBytesWritten) of \(totalBytesExpectedToWrite)")
        }
    }
    
    func getDetails(fromRemoteURL url: URL) -> Download? {
        for details in self.downloads {
            if (details.remoteURL == url) {
                return details
            }
        }
        
        return nil
    }
    
    func downloadComplete(forRemoteURL remoteURL: URL,
                          toLocalURL localURL: URL) {
        if let details = getDetails(fromRemoteURL: remoteURL) {
            let detailsIndex = self.downloads.index(of: details)
            self.downloads.remove(at: detailsIndex!)
            
            let mediaIndex = MediaManager.shared.addMedia(url: localURL)
            
            details.index = mediaIndex
            
            delegate?.downloadCompleted(download: details)
        }
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
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        // Success
        if let statusCode = (downloadTask.response as? HTTPURLResponse)?.statusCode {
            print("Success: \(statusCode)")
        }
        
        let remoteURL = (downloadTask.currentRequest?.url)!
        let localURL = makeFileDownloadURL(downloadURL: remoteURL)
        
        do {
            try FileManager.default.copyItem(at: location, to: localURL)
            //completion()
        } catch (let writeError) {
            print("Error writing file \(localURL) : \(writeError)")
        }
        
        downloadComplete(forRemoteURL: remoteURL,
                         toLocalURL: localURL)
        
        // TODO: Need to tell the VC that we have finished downloading and updated the contents 
        //       of the arrays...
        
        debugPrint("Did finish downloading")
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(String(describing: error))")
        
    }
    
    func calculateProgress(session: URLSession,
                           completionHandler: @escaping (Float) -> ()) {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            let bytesReceived = downloads.map{ $0.countOfBytesReceived }.reduce(0, +)
            let bytesExpectedToReceive = downloads.map{ $0.countOfBytesExpectedToReceive }.reduce(0, +)
            let progress = bytesExpectedToReceive > 0 ? Float(bytesReceived) / Float(bytesExpectedToReceive) : 0.0
            completionHandler(progress)
        }
    }
}
