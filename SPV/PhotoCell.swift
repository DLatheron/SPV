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
    
    func configure(withMedia media: Media) {
        imageView.image = media.getImage()
    }
}
