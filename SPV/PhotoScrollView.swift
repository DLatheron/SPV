//
//  PhotoScrollView.swift
//  SPV
//
//  Created by dlatheron on 11/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol Fullscreen {
    var isFullscreen: Bool {
        get
    }
}


class PhotoScrollView : UIScrollView, UIScrollViewDelegate {
    var fullscreen: Fullscreen
    var imageView: UIImageView
    
    
    init(parentView: UIView,
         forImage image: UIImage,
         fullscreen: Fullscreen) {
        let imageView = UIImageView()
        imageView.image = image
        imageView.sizeToFit()
        
        self.fullscreen = fullscreen
        self.imageView = imageView
        
        super.init(frame: parentView.bounds)
        
        backgroundColor = UIColor.white
        contentSize = imageView.bounds.size
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        delegate = self
        minimumZoomScale = 1.0
        maximumZoomScale = 6.0
        zoomScale = 1.0
        
        addSubview(imageView)
        parentView.addSubview(self)
        
        framePhoto()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func framePhoto() {
        centreImage()
        setZoomScale()
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        minimumZoomScale = min(widthScale, heightScale)
        zoomScale = min(widthScale, heightScale)
    }
    
    func centreImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        contentInset = UIEdgeInsets(top: max(verticalPadding, fullscreen.isFullscreen ? 0 : 64),
                                    left: horizontalPadding,
                                    bottom: max(verticalPadding, fullscreen.isFullscreen ? 0 : 44),
                                    right: horizontalPadding)
    }
    
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centreImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
