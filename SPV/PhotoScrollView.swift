//
//  PhotoScrollView.swift
//  SPV
//
//  Created by dlatheron on 11/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoScrollViewDelegate {
    var isFullscreen: Bool {
        get
    }
    var isFullyZoomedOut: Bool {
        get
        set
    }
}

class PhotoScrollView : UIScrollView {
    var psvDelegate: PhotoScrollViewDelegate
    var imageView: UIImageView
    var parentView: UIView
    
    
    init(parentView: UIView,
         forImage image: UIImage,
         psvDelegate: PhotoScrollViewDelegate) {
        let imageView = UIImageView()
        imageView.image = image
        imageView.sizeToFit()
        
        self.psvDelegate = psvDelegate
        self.imageView = imageView
        self.parentView = parentView
        
        super.init(frame: UIScreen.main.bounds)
        
        parentView.isUserInteractionEnabled = true
        isUserInteractionEnabled = true
        self.imageView.isUserInteractionEnabled = true
        
        backgroundColor = UIColor.white
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
        
        trackZoomScale(zoomScale)
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
    
//    override func touchesBegan(_ touches: Set<UITouch>,
//                               with event: UIEvent?) {
//        //print("ScrollView - touchesBegan")
//        parentView.touchesBegan(touches,
//                                with: event)
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>,
//                               with event: UIEvent?) {
//        //print("ScrollView - touchesMoved")
//        parentView.touchesMoved(touches,
//                                with: event)
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>,
//                               with event: UIEvent?) {
//        //print("ScrollView - touchesEnded")
//        parentView.touchesEnded(touches,
//                                with: event)
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>,
//                                   with event: UIEvent?) {
//        //print("ScrollView - touchesCancelled")
//        parentView.touchesCancelled(touches,
//                                    with: event)
//    }
//
//    override func touchesEstimatedPropertiesUpdated(_ touches: Set<UITouch>) {
//        //print("ScrollView - touchesEstimatedPropertiesUpdated")
//        parentView.touchesEstimatedPropertiesUpdated(touches)
//    }
}
    
extension PhotoScrollView : UIScrollViewDelegate {
    func trackZoomScale(_ zoomScale: CGFloat) {
        if zoomScale == minimumZoomScale {
            print("Fully Zoomed Out: \(zoomScale)")
            psvDelegate.isFullyZoomedOut = true
        } else {
            print("Zoom: \(zoomScale)")
            psvDelegate.isFullyZoomedOut = false
        }
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centreImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView,
                                 with view: UIView?,
                                 atScale scale: CGFloat) {
        trackZoomScale(scale)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
