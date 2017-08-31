//
//  DownloadingCell.swift
//  SPV
//
//  Created by dlatheron on 15/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class DownloadingCell : UITableViewCell {
    
    @IBOutlet weak var progressView: CircularProgressIndicator!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var pauseResumeButton: UIButton!
    
    var download: Download? = nil
    
    deinit {
        if let download = download {
            download.changedEvent = nil
        }
    }
    
    @IBAction func pauseOrResumeDownload(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        
        button.isSelected ? resumeDownload() : pauseDownload()
    }
    
    func downloadPropertyChanged(_ propertyChanged: String) {
        print("PropertyChanged \(propertyChanged) - refresh this cell")
        
        // TODO: Tell the owning tabl
    }
    
    func pauseDownload() {
        print("TODO: Pause the associated download.")
        
        download?.pause = true
        pauseResumeButton.isSelected = true
        
        updateCell()
    }
    
    func resumeDownload() {
        print("TODO: Resume the associated download.")

        download?.pause = false
        pauseResumeButton.isSelected = false

        updateCell()
    }
    
    func updateCell() {
        if let download = download {
            DispatchQueue.main.async() {
                self.title.text = download.name
                if (download.pause) {
                    self.title.textColor = UIColor.lightGray
                    
                    self.status.text = ""
                    
                } else {
                    self.title.textColor = UIColor.darkText
                    
                    let timeRemaining = HumanReadable.duration(duration: download.timeRemainingInSeconds)
                    let downloadSpeed = HumanReadable.bps(bytesPerSecond: download.downloadSpeedInBPS)

                    self.status.text = "Remaining: \(timeRemaining), Speed: \(downloadSpeed))"
                }
                
                self.progressView.progress = download.progress
            }
        }
    }
}

