//
//  PhotoDetailsViewController.swift
//  SPV
//
//  Created by David Latheron on 06/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class PhotoDetailsViewController : UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var filePath: String = ""
    var image: UIImage! = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.hidesBarsOnTap = true
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        imageView.image = image
        imageView.sizeToFit()

        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = UIColor.white
        scrollView.contentSize = imageView.bounds.size
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.zoomScale = 1.0
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)

        // TODO: Setup gesture recogniser for single tap to remove the top and bottom bars...
        setupGestureRecognizers()
    }
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
        centreImage()
    }
    
    override var prefersStatusBarHidden: Bool {
        return navigationController?.isNavigationBarHidden == true
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = scrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        scrollView.minimumZoomScale = min(widthScale, heightScale)
        scrollView.zoomScale = 1.0
    }
    
    func centreImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        // TODO: Handle the dynamic nature of the bars - turned on and off by single tap.
        scrollView.contentInset = UIEdgeInsets(top: max(verticalPadding, 64),
                                               left: horizontalPadding,
                                               bottom: max(verticalPadding, 44),
                                               right: horizontalPadding)
    }
    
    //MARK: - Gesture recognition
    func setupGestureRecognizers() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        scrollView.addGestureRecognizer(singleTap)
        
        singleTap.require(toFail: doubleTap)
    }
    
    func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        // TODO: Also zoom into the point tapped...
        if (scrollView.zoomScale > scrollView.minimumZoomScale) {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        let currentState = navigationController?.isNavigationBarHidden == false

        navigationController?.setNavigationBarHidden(currentState, animated: true)
        setTabBarVisible(visible: !currentState, animated: true)
    }
    
    //MARK: - Tab bar hiding
    func setTabBarVisible(visible:Bool, animated:Bool) {
        //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time
        
        if (tabBarIsVisible() == visible) { return }
        
        // Get a frame calculation ready
        let frame = self.tabBarController?.tabBar.frame
        let height = frame?.size.height
        let offsetY = (visible ? -height! : height)
        
        // Zero duration means no animation
        let duration:TimeInterval = (animated ? 0.3 : 0.0)
        
        // Animate the tab bar
        if frame != nil {
            UIView.animate(withDuration: duration) {
                self.tabBarController?.tabBar.frame = frame!.offsetBy(dx: 0, dy: offsetY!)
                return
            }
        }
    }
    
    func tabBarIsVisible() ->Bool {
        return (self.tabBarController?.tabBar.frame.origin.y)! < self.view.frame.maxY
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centreImage()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
