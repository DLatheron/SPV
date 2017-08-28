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
    
    deinit {
        removeObserver(self,
                       forKeyPath: #keyPath(download.percentage))
    }
    
    var download: Download? = nil {
        willSet(newDownload) {
            if download != nil {
                removeObserver(self,
                                forKeyPath: #keyPath(download.percentage))
            }
        }
        didSet {
            if download != nil {
                addObserver(self,
                            forKeyPath: #keyPath(download.percentage),
                            options: [.new, .old],
                            context: nil)
            }
        }
    }

    
    @IBAction func pauseOrResumeDownload(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        
        button.isSelected ? resumeDownload() : pauseDownload()
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(download.percentage) {
            progressView.progress = (download?.percentage)!
        }
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
        if let download = self.download {
            title.text = download.name
            if (download.pause) {
                title.textColor = UIColor.lightGray
                
                status.text = ""
                
            } else {
                title.textColor = UIColor.darkText
                
                let timeRemaining = Download.humanReadableDuration(duration: download.timeRemainingInSeconds)
                let downloadSpeed = Download.humanReadableBPS(bytesPerSecond: download.downloadSpeedInBPS)

                status.text = "Remaining: \(timeRemaining), Speed: \(downloadSpeed))"
            }
            
            progressView.progress = download.percentage
        }
    }
}

