//
//  PhotoCell.swift
//  SPV
//
//  Created by dlatheron on 04/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var media: Media? = nil
    
    
    func configure(withMedia media: Media) {
        self.media = media
        
        imageView.image = media.getImage()
    }
}
