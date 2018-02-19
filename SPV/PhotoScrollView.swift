//
//  PhotoScrollView.swift
//  SPV
//
//  Created by dlatheron on 11/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

// TODO: Move single tap gesture recogniser into here??? Then callback to remove the appropriate hud elements???
// TODO: Move double tap gesture recogniser (at least the response)

import Foundation
import UIKit

class PhotoScrollView : MediaScrollView {
    var imageView = UIImageView()
    
    init(parentView: UIView,
         forImage image: UIImage,
         psvDelegate: PhotoScrollViewDelegate) {
        
        imageView.image = image
        imageView.sizeToFit()
        
        super.init(parentView: parentView,
                   contentView: imageView,
                   psvDelegate: psvDelegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
