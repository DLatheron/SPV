//
//  DownloadsViewController.swift
//  SPV
//
//  Created by dlatheron on 15/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class DownloadDetails : NSObject {
    var name: String
    var timeRemaining: String
    var downloadSpeed: String
    dynamic var percentage: Double
    var isPaused: Bool
    
    
    
    init(name: String,
         timeRemaining: String,
         downloadSpeed: String,
         percentage: Double,
         isPaused: Bool = false) {
        self.name = name
        self.timeRemaining = timeRemaining
        self.downloadSpeed = downloadSpeed
        self.percentage = percentage
        self.isPaused = isPaused
    }
}

class DownloadsViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var downloadsTableView: UITableView!
    
    let sections = [
        "Active",
        "Completed"
    ]
    
    var downloading = [
        DownloadDetails(name: "pic0.jpg", timeRemaining: "0:15", downloadSpeed: "32Kb/s", percentage: 0.9),
        DownloadDetails(name: "pic1.jpg", timeRemaining: "1:00:00", downloadSpeed: "0.1Kb/s", percentage: 0.01),
        DownloadDetails(name: "pic2.jpg", timeRemaining: "0:02", downloadSpeed: "12Kb/s", percentage: 0.99),
        DownloadDetails(name: "pic3.jpg", timeRemaining: "3:45", downloadSpeed: "0Kb/s", percentage: 0.45),
        DownloadDetails(name: "pic4.jpg", timeRemaining: "5:00", downloadSpeed: "11Kb/s", percentage: 0.1),
        DownloadDetails(name: "pic5.jpg", timeRemaining: "0:56", downloadSpeed: "12Mb/s", percentage: 0.3),
        DownloadDetails(name: "pic6.jpg", timeRemaining: "0:18", downloadSpeed: "8Kb/s", percentage: 0.6),
        DownloadDetails(name: "pic7.jpg", timeRemaining: "0:12", downloadSpeed: "345Kb/s", percentage: 0.8),
        DownloadDetails(name: "pic8.jpg", timeRemaining: "0:34", downloadSpeed: "23Kb/s", percentage: 0.4),
        DownloadDetails(name: "pic9.jpg", timeRemaining: "0:44", downloadSpeed: "19Kb/s", percentage: 0.2)
    ]
    
    var completed = [
        (name: "pic10.jpg", size: "45KB", time: "3:20", index: 0),
        (name: "pic11.jpg", size: "45KB", time: "3:20", index: 1),
        (name: "pic12.jpg", size: "45KB", time: "3:20", index: 2),
        (name: "pic13.jpg", size: "45KB", time: "3:20", index: 3),
        (name: "pic14.jpg", size: "45KB", time: "3:20", index: 4)
    ]
    
    var photoManager: PhotoManager?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            return downloading.count
        } else {
            return completed.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Different types depending on the section???
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadingCell")! as! DownloadingCell
            
            cell.downloadDetails = downloading[indexPath.row]
            cell.updateCell()
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CompletedCell")! as! CompletedCell

            cell.title.text = completed[indexPath.row].name
            cell.status.text = "Size: \(completed[indexPath.row].size), Time: \(completed[indexPath.row].time)"
            cell.downloadedImageView.image = photoManager?.getPhotoImage(at: completed[indexPath.row].index)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        if (section == 1 && completed.count == 0) {
            return nil
        }
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 1 && completed.count == 0) {
            return 0
        }
        return 60
    }
    
    @IBAction func returnToBrowserViewController(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToBrowserViewController",
                     sender: self)
    }
    
    @IBAction func clearCompletedDownloads(_ sender: Any) {
        completed = [];
        
        downloadsTableView.reloadSections(IndexSet(integer: 1),
                                          with: UITableViewRowAnimation.fade)
    }
}
