//
//  MediaInfoHeaderCell.swift
//  SPV
//
//  Created by dlatheron on 13/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class MediaInfoHeaderCell : UITableViewCell {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(withMedia media: Media) {
        mediaImageView.image = media.getImage()
        
        titleLabel.text = media.mediaInfo.title
    }
}
