//
//  DownloadsViewController.swift
//  SPV
//
//  Created by dlatheron on 15/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol DownloadPauseResumeProtocol: class {
    func pauseDownload(forCell cell: DownloadingCell)
    func resumeDownload(forCell cell: DownloadingCell)
}

class DownloadsViewController : UIViewController {
    @IBOutlet weak var downloadsTableView: UITableView!

    let downloadManager: DownloadManagerBase
    
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
    
    var downloads: [Download] = []
    var completed: [Download] = []
    
    required init(coder aDecoder: NSCoder) {
        downloadManager = DownloadManager.shared
        //downloadManager = FakeDownloadManager.shared

        super.init(coder: aDecoder)!

        downloadManager.delegate = self
        downloads = downloadManager.downloads
        completed = downloadManager.completed
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
        downloadManager.clearCompletedDownloads()
        
        completed = downloadManager.completed
        
        downloadsTableView.reloadSections([Sections.completed.rawValue],
                                          with: .automatic)
    }
}

extension DownloadsViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if section == Sections.completed.rawValue && completed.count == 0 {
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
        if section == Sections.completed.rawValue && completed.count == 0 {
            return nil
        } else {
            return sectionTitles[section]
        }
    }
    
    // Download for IndexPath???
    func getDownload(for indexPath: IndexPath) -> Download {
        if indexPath.section == Sections.downloads.rawValue {
            return downloads[indexPath.row]
        } else if indexPath.section == Sections.completed.rawValue {
            return completed[indexPath.row]
        } else {
            fatalError("Unexpected section")
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadingCell", for: indexPath) as? DownloadingCell {
            let download = getDownload(for: indexPath)
            
            cell.configure(withDownload: download)
            cell.delegate = self

            return cell
        }
        
        return UITableViewCell()
    }
}

extension DownloadsViewController : DownloadChangedProtocol {
    func downloadChanged(download: Download) {
        DispatchQueue.main.async {
            if let row = self.downloads.index(of: download) {
                let indexPath = IndexPath(row: row,
                                          section: Sections.downloads.rawValue)
                let cell = self.downloadsTableView.cellForRow(at: indexPath) as? DownloadingCell
                cell?.configure(withDownload: download)
            } else {
                let row = 0
                let indexPath = IndexPath(row: row,
                                          section: Sections.downloads.rawValue)
                self.downloads.insert(download, at: Sections.downloads.rawValue);
                self.downloadsTableView.insertRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func downloadCompleted(download: Download) {
        assert(download.index != nil)
        
        DispatchQueue.main.async {
            if let srcRow = self.downloads.index(of: download) {
                let dstRow = 0
                
                self.downloads.remove(at: srcRow)
                self.completed.insert(download, at: dstRow)

                let srcIndexPath = IndexPath(row: srcRow,
                                             section: Sections.downloads.rawValue)
                let dstIndexPath = IndexPath(row: dstRow,
                                             section: Sections.completed.rawValue)
                
                self.downloadsTableView.moveRow(at: srcIndexPath,
                                                to: dstIndexPath)
                
                let cell = self.downloadsTableView.cellForRow(at: dstIndexPath) as? DownloadingCell
                
                cell?.configure(withDownload: download)
            }
        }
    }
}

extension DownloadsViewController : DownloadPauseResumeProtocol {
    func getDownload(forCell cell: DownloadingCell) -> Download? {
        if let indexPath = self.downloadsTableView.indexPath(for: cell) {
            return getDownload(for: indexPath)
        } else {
            return nil
        }
    }
    
    func pauseDownload(forCell cell: DownloadingCell) {
        if let download = getDownload(forCell: cell) {
            downloadManager.pause(download: download)
            if !download.pause {
                download.pause = true
                cell.configure(withDownload: download)
            }
        }
    }

    func resumeDownload(forCell cell: DownloadingCell) {
        if let download = getDownload(forCell: cell) {
            downloadManager.resume(download: download)
            if download.pause {
                download.pause = false
                cell.configure(withDownload: download)
            }
        }
    }
}
