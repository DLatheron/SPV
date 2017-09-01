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
    
    @IBOutlet weak var downloadedImageView: UIImageView!
    @IBOutlet weak var progressView: CircularProgressIndicator!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var pauseResumeButton: UIButton!
    
    weak var delegate: DownloadPauseResumeProtocol?
    
    @IBAction func pauseOrResumeDownload(_ sender: Any) {
        let button: UIButton = sender as! UIButton
        
        button.isSelected ? resumeDownload() : pauseDownload()
    }
    
    func downloadPropertyChanged(_ propertyChanged: String) {
        print("PropertyChanged \(propertyChanged) - refresh this cell")
        
        // TODO: Tell the owning tabl
    }
    
    func pauseDownload() {
        pauseResumeButton.isSelected = true
        delegate?.pauseDownload(forCell: self)
    }
    
    func resumeDownload() {
        pauseResumeButton.isSelected = false
        delegate?.resumeDownload(forCell: self)
    }
    
    func configure(withDownload download: Download) {
        if download.index != nil {
            configureCompleteCell(for: download)
        } else {
            configureActiveCell(for: download)
        }
    }
    
    private func configureCompleteCell(for download: Download) {
        title.text = download.name
        title.textColor = UIColor.darkText
        
        let size = HumanReadable.bytes(bytes: download.totalSizeInBytes,
                                       units: .bytes,
                                       space: false)
        let time = HumanReadable.duration(duration: download.durationInSeconds)
        
        status.text = "Size: \(size), Time: \(time)"
        
        downloadedImageView.image = MediaManager.shared.getPhotoImage(at: download.index!)
        
        downloadedImageView.isHidden = false
        pauseResumeButton.isHidden = true
        progressView.isHidden = true
    }
    
    private func configureActiveCell(for download: Download) {
        title.text = download.name
        
        if (download.pause) {
            title.textColor = UIColor.lightGray
            status.text = ""
        } else {
            title.textColor = UIColor.darkText
            
            let time = HumanReadable.duration(duration: download.timeRemainingInSeconds)
            let speed = HumanReadable.bps(bytesPerSecond: download.downloadSpeedInBPS)
            
            status.text = "Remaining: \(time), Speed: \(speed)"
        }
        
        progressView.progress = download.progress
        
        
        downloadedImageView.isHidden = true
        pauseResumeButton.isHidden = false
        progressView.isHidden = false
    }
}

