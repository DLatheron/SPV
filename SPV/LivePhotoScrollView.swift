//
//  LivePhotoScrollView.swift
//  SPV
//
//  Created by dlatheron on 11/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

// TODO: Move single tap gesture recogniser into here??? Then callback to remove the appropriate hud elements???
// TODO: Move double tap gesture recogniser (at least the response)

import Foundation
import UIKit
import PhotosUI

class LivePhotoScrollView : MediaScrollView {
    var livePhotoView: PHLivePhotoView
    var requestID: PHLivePhotoRequestID = PHLivePhotoRequestIDInvalid
    
    init(parentView: UIView,
         forLivePhoto livePhoto: LivePhoto,
         psvDelegate: PhotoScrollViewDelegate) {
        
        livePhotoView = PHLivePhotoView(frame: parentView.frame)

        super.init(parentView: parentView,
                   contentView: livePhotoView,
                   psvDelegate: psvDelegate)
        
        let image = livePhoto.getImage()
        let size = image.size
        
        requestID = PHLivePhoto.request(withResourceFileURLs: livePhoto.resourceFileURLs,
                                        placeholderImage: image,
                                        targetSize: size,
                                        contentMode: .default)
        { (phLivePhoto, info) in
            let error = info[PHLivePhotoInfoErrorKey] as? NSError
            let degraded = info[PHLivePhotoInfoIsDegradedKey] as? NSNumber
            let cancelled = info[PHLivePhotoInfoCancelledKey] as? NSNumber
            let finished = (
                (error != nil) ||
                    (cancelled != nil && cancelled!.boolValue == true) ||
                    (degraded != nil && degraded!.boolValue == false)
            )
            
            if finished {
                print("Live photo request finished")
                self.requestID = PHLivePhotoRequestIDInvalid
            }
            
            if let photo = phLivePhoto, photo.size == CGSize.zero {
                // Workaround for crasher rdar://24021574 (https://openradar.appspot.com/24021574)
                return;
            }
            
            if let photo = phLivePhoto {
                self.livePhotoView.livePhoto = photo
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
