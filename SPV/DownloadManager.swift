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
    
    var downloadDetails: [DownloadDetails] = []
    
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
    
    func download(url: URL, to localUrl: URL, completion: @escaping () -> ()) {
        let request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy)
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion()
                } catch (let writeError) {
                    print("Error writing file \(localUrl) : \(writeError)")
                }
                
            } else {
                print("Failure: \(error!.localizedDescription)");
            }
        }
        task.resume()
    }
    
    func refresh() {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            self.downloadDetails = downloads.map { (download) in
                DownloadDetails(name: "Test01.jpg",
                                timeRemaining: "3m",
                                downloadSpeed: "4KB/s",
                                percentage: Double(download.countOfBytesReceived) / Double(download.countOfBytesExpectedToReceive),
                                isPaused: false)
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
            let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
            debugPrint("Downloaded \(totalBytesWritten) of \(totalBytesExpectedToWrite) = \(progress)")
        }
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        debugPrint("Did finished downloading")
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        debugPrint("Task completed: \(task), error: \(error ?? "" as! Error)")
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
