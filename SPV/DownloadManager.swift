//
//  DownloadManager.swift
//  SPV
//
//  Created by David Latheron on 13/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation


class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate {
    static var shared = DownloadManager()
    
    var downloading: [DownloadDetails] = []
    var completed: [DownloadDetails] = []
    
    override init() {
        super.init()
        
        let details = DownloadDetails(remoteURL: URL(string: "http://image.jpg")!)
        details.downloadComplete(atIndex: 0)
        
        completed.append(details)
    }
    
    var session : URLSession {
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
        
        self.downloading.append(DownloadDetails(remoteURL: remoteURL))
        
        let task = session.downloadTask(with: request)
        task.resume()
    }
    
    func refresh() {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            self.downloading = downloads.map { (download) in
                let remoteURL = (download.currentRequest?.url)!
            
                return DownloadDetails(remoteURL: remoteURL)
            }
        }
    }
    
    func clearCompletedDownloads() {
        completed = []
    }
    
    
    // MARK: - URLSessionDownloadDelegate
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        if totalBytesExpectedToWrite > 0 {
            let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
            
            updateProgress(forRemoteURL: (downloadTask.currentRequest?.url)!,
                           progress: progress)
            
            debugPrint("Downloaded \(totalBytesWritten) of \(totalBytesExpectedToWrite) = \(progress)")
        }
    }
    
    func getDetails(fromRemoteURL url: URL) -> DownloadDetails? {
        for details in downloading {
            if (details.remoteURL == url) {
                return details
            }
        }
        
        return nil
    }
    
    func updateProgress(forRemoteURL remoteURL: URL,
                        progress: Double) {
        if let details = getDetails(fromRemoteURL: remoteURL) {
            details.percentage = progress
        }
    }
    
    func downloadComplete(forRemoteURL remoteURL: URL,
                          toLocalURL localURL: URL) {
        if let details = getDetails(fromRemoteURL: remoteURL) {
            let detailsIndex = downloading.index(of: details)
            downloading.remove(at: detailsIndex!)
            
            let mediaIndex = MediaManager.shared.addMedia(url: localURL)
            
            details.downloadComplete(atIndex: mediaIndex)
            
            completed.insert(details, at: 0)
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
        
        debugPrint("Did finished downloading")
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
