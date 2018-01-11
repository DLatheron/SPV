//
//  MediaInfoHeaderCell.swift
//  SPV
//
//  Created by dlatheron on 13/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

class MediaInfoHeaderCell : UITableViewCell {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratings: CosmosView!
    
    func configure(withMedia media: Media) {
        mediaImageView.image = media.getImage()
        
        titleLabel.text = media.mediaInfo.title
        ratings.rating = Double(media.mediaInfo.rating)
        
        ratings.didFinishTouchingCosmos = {
            print("Rating updated to \($0)")
            media.mediaInfo.rating = Int($0)
            media.save()
        }
    }
}
