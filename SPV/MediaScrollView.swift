//
//  MediaScrollView.swift
//  SPV
//
//  Created by dlatheron on 19/02/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class MediaScrollView : UIScrollView {
    var parentView: UIView
    var contentView: UIView
    var psvDelegate: PhotoScrollViewDelegate

    init(parentView: UIView,
         contentView: UIView,
         psvDelegate: PhotoScrollViewDelegate) {
        self.parentView = parentView
        self.contentView = contentView
        self.psvDelegate = psvDelegate

        super.init(frame: UIScreen.main.bounds)
        
        autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth, .flexibleHeight]
        
        self.delegate = self
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 6.0
        self.zoomScale = 1.0
        
        contentView.frame = parentView.frame;
        contentView.setNeedsLayout()
        
        addSubview(contentView)
        
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
        let imageViewSize = contentView.bounds.size
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
        let imageViewSize = contentView.frame.size
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

extension MediaScrollView : EmbeddedMediaViewDelegate {
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

extension MediaScrollView : UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centreImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                 with view: UIView?,
                                 atScale scale: CGFloat) {
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.contentView
    }
}
