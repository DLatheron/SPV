//
//  DownloadsViewController.swift
//  SPV
//
//  Created by dlatheron on 15/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit


class DownloadsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var downloadsTableView: UITableView!
    
    let sections = [
        "Active",
        "Completed"
    ]

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DownloadManager.shared.refresh();
        
        downloadsTableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        downloadsTableView.allowsSelection = false
        downloadsTableView.sectionIndexMinimumDisplayRowCount = 99
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections;
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return DownloadManager.shared.downloading.count
        } else {
            return DownloadManager.shared.completed.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadingCell")! as! DownloadingCell
            let download = DownloadManager.shared.downloading[indexPath.row]
            
            download.changedEvent = { changedPropertyName in
                cell.updateCell()
            }
        
            cell.download = download
            cell.updateCell()
        
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedCell")! as! CompletedCell

            cell.download = DownloadManager.shared.completed[indexPath.row]
            cell.updateCell()
            
            return cell
            
        default:
            fatalError("Invalid Section Index \(indexPath.section)")
        }
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        if (section == 1 && DownloadManager.shared.completed.count == 0) {
            return nil
        }
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1 && DownloadManager.shared.completed.count == 0) {
            return 0
        }
        return 60
    }
    
    @IBAction func returnToBrowserViewController(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToBrowserViewController",
                     sender: self)
    }
    
    @IBAction func clearCompletedDownloads(_ sender: Any) {
        DownloadManager.shared.clearCompletedDownloads()
        
        downloadsTableView.reloadSections(IndexSet(integer: 1),
                                          with: UITableViewRowAnimation.fade)
    }
}
