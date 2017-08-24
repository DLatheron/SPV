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
    
    var downloadDetails: DownloadDetails? = nil
    
    func updateCell() {
        if let downloadDetails = self.downloadDetails {
            title.text = downloadDetails.name
            status.text = "Size: \(downloadDetails.size), Time: \(downloadDetails.time)"
            downloadedImageView.image = MediaManager.shared.getPhotoImage(at: downloadDetails.index!)
        }
    }
}
