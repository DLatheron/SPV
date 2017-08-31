//
//  DownloadManager.swift
//  SPV
//
//  Created by David Latheron on 13/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class DownloadManager : NSObject, URLSessionDelegate, URLSessionDownloadDelegate, UITableViewDataSource, UITableViewDelegate {
    static var shared = DownloadManager()
    
    class Section {
        let title: String
        var entries: [Download]
        
        init(title: String) {
            self.title = title
            self.entries = []
        }
    }
    
    private var sections = [
        Section(title: "Active"),
        Section(title: "Completed")
    ]
    
    override init() {
        super.init()

        initExistingDownloads()
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
        
        self.sections[0].entries.append(download)
        
        // We have added a new item into the list, so we need to refresh the table
        // 
        
        let task = session.downloadTask(with: request)
        task.resume()
        download.pause = false
    }
    
    func initExistingDownloads() {
        session.getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            self.sections[0].entries = downloads.map { (download) in
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
        for details in sections[0].entries {
            if (details.remoteURL == url) {
                return details
            }
        }
        
        return nil
    }
    
    func downloadComplete(forRemoteURL remoteURL: URL,
                          toLocalURL localURL: URL) {
        if let details = getDetails(fromRemoteURL: remoteURL) {
            let detailsIndex = sections[0].entries.index(of: details)
            sections[0].entries.remove(at: detailsIndex!)
            
            let mediaIndex = MediaManager.shared.addMedia(url: localURL)
            
            details.index = mediaIndex
            
            sections[1].entries.insert(details, at: 0)
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
    
    func clearCompletedDownloads(in tableView: UITableView) {
        sections[1].entries = []
        
        tableView.reloadSections(IndexSet(integer: 1),
                                 with: UITableViewRowAnimation.fade)
    }
    
    // MARK:- UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { section in
            return section.title
        }
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return sections[section].entries.count
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        if (sections[section].entries.count == 0) {
            return nil
        } else {
            return sections[section].title
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section;
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadingCell")! as! DownloadingCell
            
            cell.download = sections[section].entries[indexPath.row]
            cell.updateCell()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedCell")! as! CompletedCell
            
            cell.download = sections[section].entries[indexPath.row]
            cell.updateCell()
            
            return cell
        }
    }
    
    // MARK:- UITableViewDelegate
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1 && sections[section].entries.count == 0) {
            return 0
        }
        return 60
    }
}
