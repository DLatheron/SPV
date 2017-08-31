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

    let downloadManager: DownloadManager
    
    required init(coder aDecoder: NSCoder) {
        downloadManager = DownloadManager.shared

        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadsTableView.delegate = downloadManager
        downloadsTableView.dataSource = downloadManager

        downloadManager.refresh();
        
        downloadsTableView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 0, right: 0)
        downloadsTableView.allowsSelection = false
        downloadsTableView.sectionIndexMinimumDisplayRowCount = 99
    }
    
    @IBAction func returnToBrowserViewController(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToBrowserViewController",
                     sender: self)
    }
    
    @IBAction func clearCompletedDownloads(_ sender: Any) {
        downloadManager.clearCompletedDownloads(in: downloadsTableView)
    }
}
