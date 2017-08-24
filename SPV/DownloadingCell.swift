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
                       forKeyPath: #keyPath(downloadDetails.percentage))
    }
    
    var downloadDetails: DownloadDetails? = nil {
        willSet(newDownloadDetails) {
            if downloadDetails != nil {
                removeObserver(self,
                                forKeyPath: #keyPath(downloadDetails.percentage))
            }
        }
        didSet {
            if downloadDetails != nil {
                addObserver(self,
                            forKeyPath: #keyPath(downloadDetails.percentage),
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
        if keyPath == #keyPath(downloadDetails.percentage) {
            progressView.progress = (downloadDetails?.percentage)!
        }
    }
    
    func pauseDownload() {
        print("TODO: Pause the associated download.")
        
        downloadDetails?.isPaused = true
        pauseResumeButton.isSelected = true
        
        updateCell()
    }
    
    func resumeDownload() {
        print("TODO: Resume the associated download.")

        downloadDetails?.isPaused = false
        pauseResumeButton.isSelected = false

        updateCell()
    }
    
    func updateCell() {
        if let downloadDetails = self.downloadDetails {
            title.text = downloadDetails.name
            if (downloadDetails.isPaused) {
                title.textColor = UIColor.lightGray
                
                status.text = ""
                
            } else {
                title.textColor = UIColor.darkText

                status.text = "Remaining: \(downloadDetails.timeRemaining), Speed: \(downloadDetails.downloadSpeed)"
            }
            
            progressView.progress = downloadDetails.percentage
        }
    }
}

