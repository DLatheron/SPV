//
//  CompletedCell.swift
//  SPV
//
//  Created by dlatheron on 15/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//


import Foundation
import UIKit

class CompletedCell : UITableViewCell {
    
    @IBOutlet weak var downloadedImageView: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var status: UILabel!
    
    func configure(withDownload download: Download) {
        title.text = download.name
        status.text = "Size: \(download.totalSizeInBytes), Time: \(HumanReadable.duration(duration: download.timeRemainingInSeconds))"
        downloadedImageView.image = MediaManager.shared.getPhotoImage(at: 0)//download.index!)
    }
}
