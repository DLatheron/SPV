//
//  LivePhotoScrollView.swift
//  SPV
//
//  Created by dlatheron on 11/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

// TODO: Move single tap gesture recogniser into here??? Then callback to remove the appropriate hud elements???
// TODO: Move doulbe tap gesture recogniser (at least the response)

import Foundation
import UIKit
import PhotosUI

class LivePhotoScrollView : UIScrollView {
    var psvDelegate: PhotoScrollViewDelegate
    var imageView: PHLivePhotoView
    var parentView: UIView
    
    init(parentView: UIView,
         forImage image: UIImage,
         psvDelegate: PhotoScrollViewDelegate) {
        let imageView = PHLivePhotoView()
        //imageView.image = image
        imageView.sizeToFit()
        
        self.psvDelegate = psvDelegate
        self.imageView = imageView
        self.parentView = parentView
        
        super.init(frame: UIScreen.main.bounds)
        
        backgroundColor = UIColor.black
        contentSize = imageView.bounds.size
        autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth, .flexibleHeight]
        
        delegate = self
        minimumZoomScale = 1.0
        maximumZoomScale = 6.0
        zoomScale = 1.0
        
        addSubview(imageView)
        
        framePhoto()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func framePhoto() {
        centreImage()
        calcZoomScale()
        setZoomScale()
    }
    
    func setZoomScale() {
        calcZoomScale()
        
        zoomScale = minimumZoomScale
    }
    
    func calcZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        minimumZoomScale = min(min(widthScale, heightScale), 1.0)
        maximumZoomScale = 6
        
        if zoomScale < minimumZoomScale {
            zoomScale = minimumZoomScale
        } else if zoomScale > maximumZoomScale {
            zoomScale = maximumZoomScale
        }
    }
    
    func centreImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = frame.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        let bottomOffset = CGFloat(psvDelegate.isFullscreen ? -50 : 0)
        
        contentInset = UIEdgeInsets(top: verticalPadding,
                                    left: horizontalPadding,
                                    bottom: verticalPadding + bottomOffset,
                                    right: horizontalPadding)
        
        scrollIndicatorInsets = UIEdgeInsets(top: 0,
                                             left: 0,
                                             bottom: bottomOffset,
                                             right: 0)
    }
}

extension LivePhotoScrollView : EmbeddedMediaViewDelegate {
    var isFullyZoomedOut: Bool {
        get {
            return zoomScale == minimumZoomScale
        }
    }
    
    var view: UIView {
        get {
            return self
        }
    }
    
    func willRotate(parentView: UIView) {
        centreImage()
        calcZoomScale()
    }
    
    func didRotate(parentView: UIView) {
    }
    
    func remove() {
        removeFromSuperview()
    }
    
    func singleTap() {
        centreImage()
    }
    
    func doubleTap() {
        if zoomScale > minimumZoomScale {
            setZoomScale(minimumZoomScale,
                         animated: true)
        } else {
            setZoomScale()
            setZoomScale(maximumZoomScale,
                         animated: true)
        }
    }
}

extension LivePhotoScrollView : UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centreImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                 with view: UIView?,
                                 atScale scale: CGFloat) {
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}

