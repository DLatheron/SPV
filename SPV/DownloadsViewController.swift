//
//  DownloadsViewController.swift
//  SPV
//
//  Created by dlatheron on 15/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit


class DownloadsViewController : UIViewController {
    @IBOutlet weak var downloadsTableView: UITableView!

    let downloadManager: FakeDownloadManager
    
    enum Sections: Int {
        case downloads = 0
        case completed = 1
    }
    
    let sectionTitles = [
        "Active",
        "Completed"
    ]
    
    let downloadSection = IndexSet(integer: 0)
    let completedSection = IndexSet(integer: 1)
    
    var downloads: [Download] = [] {
        didSet {
            downloadsTableView.reloadSections(downloadSection, with: .automatic)
        }
    }
    var completed: [Download] = [] {
        didSet {
            downloadsTableView.reloadSections(completedSection, with: .automatic)
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        //downloadManager = DownloadManager.shared
        downloadManager = FakeDownloadManager()

        super.init(coder: aDecoder)!

        downloadManager.delegate = self
        downloads = downloadManager.downloads
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadsTableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        downloadsTableView.allowsSelection = false
        downloadsTableView.sectionIndexMinimumDisplayRowCount = 99
    }
    
    @IBAction func returnToBrowserViewController(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToBrowserViewController",
                     sender: self)
    }
    
    @IBAction func clearCompletedDownloads(_ sender: Any) {
        completed = []
    }
}

extension DownloadsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if section == Sections.downloads.rawValue && downloads.count == 0 {
            return 0
        } else if section == Sections.completed.rawValue && completed.count == 0 {
            return 0
        } else {
            return 60
        }
    }
}

extension DownloadsViewController : UITableViewDataSource {
    // MARK:- UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return sectionTitles.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitles
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == Sections.downloads.rawValue {
            return downloads.count
        } else if section == Sections.completed.rawValue {
            return completed.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        if section == Sections.downloads.rawValue && downloads.count == 0 {
            return nil
        } else if section == Sections.completed.rawValue && completed.count == 0 {
            return nil
        } else {
            return sectionTitles[section]
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section;

        if section == 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadingCell", for: indexPath) as? DownloadingCell {
                let download = downloads[indexPath.row]
                
                cell.configure(withDownload: download)

                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedCell", for: indexPath) as? CompletedCell {
                let download = completed[indexPath.row]
                
                cell.configure(withDownload: download)
            
                return cell
            }
        }
        
        return UITableViewCell()
    }
}

extension DownloadsViewController : DownloadChangedProtocol {
    func allDownloadsChanged(downloads: [Download]) {
        DispatchQueue.main.async {
            self.downloads = downloads
            
            self.downloadsTableView.reloadSections(self.downloadSection, with: .automatic)
        }
    }
    
    func downloadChanged(download: Download) {
        DispatchQueue.main.async {
            if let row = self.downloads.index(of: download) {
                let indexPath = IndexPath(row: row,
                                          section: 0)
                let cell = self.downloadsTableView.cellForRow(at: indexPath) as? DownloadingCell
                cell?.configure(withDownload: download)
            }
        }
    }
    
    func downloadCompleted(download: Download) {
        DispatchQueue.main.async {
            if let srcRow = self.downloads.index(of: download) {
                let dstRow = 0
                
                self.downloads.remove(at: srcRow)
                self.completed.insert(download, at: dstRow)

                let srcIndexPath = IndexPath(row: srcRow,
                                             section: 0)
                let dstIndexPath = IndexPath(row: dstRow,
                                             section: 1)
                
                self.downloadsTableView.moveRow(at: srcIndexPath,
                                                to: dstIndexPath)
            }
        }
    }
}
