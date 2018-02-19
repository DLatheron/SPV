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
//    var psvDelegate: PhotoScrollViewDelegate
    var livePhotoView: PHLivePhotoView
//    var parentView: UIView
    var requestID: PHLivePhotoRequestID = PHLivePhotoRequestIDInvalid
    
    init(parentView: UIView,
         forLivePhoto livePhoto: LivePhoto,
         psvDelegate: PhotoScrollViewDelegate) {
        livePhotoView = PHLivePhotoView()
        
        super.init(parentView: parentView,
                   contentView: livePhotoView,
                   psvDelegate: psvDelegate)
        
//        self.psvDelegate = psvDelegate
//        self.parentView = parentView
        
        let image = livePhoto.getImage()
        let size = image.size
        
//        super.init(frame: UIScreen.main.bounds)

//        autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth, .flexibleHeight]
//
//        delegate = self
//        minimumZoomScale = 1.0
//        maximumZoomScale = 6.0
//        zoomScale = 1.0
        
//        livePhotoView.frame = parentView.frame
//
//        livePhotoView.setNeedsLayout()
//
//        addSubview(livePhotoView)
        
//        framePhoto()
        
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
    
//    func framePhoto() {
//        centreImage()
//        calcZoomScale()
//        setZoomScale()
//    }
    
//    func setZoomScale() {
//        calcZoomScale()
//
//        zoomScale = minimumZoomScale
//    }
    
//    func calcZoomScale() {
//        let imageViewSize = livePhotoView.bounds.size
//        let scrollViewSize = bounds.size
//        let widthScale = scrollViewSize.width / imageViewSize.width
//        let heightScale = scrollViewSize.height / imageViewSize.height
//
//        minimumZoomScale = min(min(widthScale, heightScale), 1.0)
//        maximumZoomScale = 6
//
//        if zoomScale < minimumZoomScale {
//            zoomScale = minimumZoomScale
//        } else if zoomScale > maximumZoomScale {
//            zoomScale = maximumZoomScale
//        }
//    }
    
//    func centreImage() {
//        let imageViewSize = livePhotoView.frame.size
//        let scrollViewSize = frame.size
//
//        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
//        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
//
//        let bottomOffset = CGFloat(psvDelegate.isFullscreen ? -50 : 0)
//
//        contentInset = UIEdgeInsets(top: verticalPadding,
//                                    left: horizontalPadding,
//                                    bottom: verticalPadding + bottomOffset,
//                                    right: horizontalPadding)
//
//        scrollIndicatorInsets = UIEdgeInsets(top: 0,
//                                             left: 0,
//                                             bottom: bottomOffset,
//                                             right: 0)
//    }
}

//extension LivePhotoScrollView : EmbeddedMediaViewDelegate {
//    var isFullyZoomedOut: Bool {
//        get {
//            return zoomScale == minimumZoomScale
//        }
//    }
//
//    var view: UIView {
//        get {
//            return self
//        }
//    }
//
//    func willRotate(parentView: UIView) {
//        centreImage()
//        calcZoomScale()
//    }
//
//    func didRotate(parentView: UIView) {
//    }
//
//    func remove() {
//        removeFromSuperview()
//    }
//
//    func singleTap() {
//        centreImage()
//    }
//
//    func doubleTap() {
//        if zoomScale > minimumZoomScale {
//            setZoomScale(minimumZoomScale,
//                         animated: true)
//        } else {
//            setZoomScale()
//            setZoomScale(maximumZoomScale,
//                         animated: true)
//        }
//    }
//}

//extension LivePhotoScrollView : UIScrollViewDelegate {
//    func scrollViewDidZoom(_ scrollView: UIScrollView) {
//        centreImage()
//    }
//
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView,
//                                 with view: UIView?,
//                                 atScale scale: CGFloat) {
//    }
//
//    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
//        return self.livePhotoView
//    }
//}

