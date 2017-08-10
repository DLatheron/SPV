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
    
    var photoManager: PhotoManager? = nil
    var index: Int = 0
    var image: UIImage! = nil
    
    var singleTap: UITapGestureRecognizer? = nil
    var doubleTap: UITapGestureRecognizer? = nil
    var swipeLeft: UISwipeGestureRecognizer? = nil
    var swipeRight: UISwipeGestureRecognizer? = nil
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imageView = PhotoDetailsViewController.createImageView(withImage: self.image)
        self.scrollView = PhotoDetailsViewController.createScrollView(inParentView: self.view,
                                                                      forImageView: self.imageView,
                                                                      withDelegate: self)
        
        title = photoManager?.getPhotoName(at: index)

        setupGestureRecognizers()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showInfo))
        
        navigationController?.isNavigationBarHidden = false
    }
    
    class func createImageView(withImage image: UIImage) -> UIImageView {
        let newImageView = UIImageView()
        newImageView.image = image
        newImageView.sizeToFit()
        
        return newImageView;
    }
    
    class func createScrollView(inParentView parentView: UIView,
                                forImageView embeddedImageView: UIImageView,
                                withDelegate delegate: UIScrollViewDelegate) -> UIScrollView {
        let newScrollView = UIScrollView(frame: parentView.bounds)
        
        newScrollView.backgroundColor = UIColor.white
        newScrollView.contentSize = embeddedImageView.bounds.size
        newScrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        newScrollView.delegate = delegate
        newScrollView.minimumZoomScale = 1.0
        newScrollView.maximumZoomScale = 6.0
        newScrollView.zoomScale = 1.0
        
        newScrollView.addSubview(embeddedImageView)
        parentView.addSubview(newScrollView)
        
        return newScrollView
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeGestureRecognizers()
    }
    
    override func viewWillLayoutSubviews() {
        PhotoDetailsViewController.framePhoto(inScrollView: self.scrollView,
                                              inImageView: self.imageView,
                                              inFullscreen: self.isFullscreen)
    }
    
    var isFullscreen: Bool {
        get {
            return navigationController?.isNavigationBarHidden == true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isFullscreen
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return UIStatusBarAnimation.slide
    }
    
    class func framePhoto(inScrollView scrollViewToUse: UIScrollView,
                          inImageView imageViewToFrame: UIImageView,
                          inFullscreen isFullscreen: Bool) {
        PhotoDetailsViewController.setZoomScale(forScrollView: scrollViewToUse,
                                                forImageView: imageViewToFrame)
        PhotoDetailsViewController.centreImage(forScrollView: scrollViewToUse,
                                               forImageView: imageViewToFrame,
                                               inFullscreen: isFullscreen)
    }
    
    func showInfo() {
        
    }
    
    class func setZoomScale(forScrollView inScrollView: UIScrollView,
                            forImageView imageViewToZoom: UIImageView) {
        let imageViewSize = imageViewToZoom.bounds.size
        let scrollViewSize = inScrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        inScrollView.minimumZoomScale = min(widthScale, heightScale)
        inScrollView.zoomScale = min(widthScale, heightScale)
    }
    
    class func centreImage(forScrollView inScrollView: UIScrollView,
                           forImageView imageViewToCentre: UIImageView,
                           inFullscreen isFullScreen: Bool) {
        let imageViewSize = imageViewToCentre.frame.size
        let scrollViewSize = inScrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        inScrollView.contentInset = UIEdgeInsets(top: max(verticalPadding, isFullScreen ? 0 : 64),
                                                 left: horizontalPadding,
                                                 bottom: max(verticalPadding, isFullScreen ? 0 : 44),
                                                right: horizontalPadding)
    }
    
    //MARK: - Gesture recognition
    func setupGestureRecognizers() {
        // Single tab for full screen.
        singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap?.numberOfTapsRequired = 1

        // Double tab for zoom.
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
        doubleTap?.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(doubleTap!)
        self.view.addGestureRecognizer(singleTap!)
        
        singleTap?.require(toFail: doubleTap!)
        
        // Swipe left for next image.
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeft?.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft!)
        
        // Swipe right for previous image.
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRight?.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight!)
    }
    
    func removeGestureRecognizers() {
        self.view.removeGestureRecognizer(singleTap!)
        self.view.removeGestureRecognizer(doubleTap!)
        self.view.removeGestureRecognizer(swipeLeft!)
        self.view.removeGestureRecognizer(swipeRight!)
    }
    
    func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        let currentState = navigationController?.isNavigationBarHidden == false
        
        navigationController?.setNavigationBarHidden(currentState, animated: true)
        setTabBarVisible(visible: !currentState, animated: true)
        
        PhotoDetailsViewController.centreImage(forScrollView: self.scrollView,
                                               forImageView: self.imageView,
                                               inFullscreen: navigationController?.isNavigationBarHidden == true)
    }
    
    func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        // TODO: Also zoom into the point tapped...
        // TODO: Multistage zoom - based on the size of the picture... no more than about 3 stages...
        if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale) {
            self.scrollView.setZoomScale(self.scrollView.minimumZoomScale, animated: true)
        } else {
            self.scrollView.setZoomScale(self.scrollView.maximumZoomScale, animated: true)
        }
    }
    
    func handleSwipeLeft(_ recognizer: UITapGestureRecognizer) {
        print("Swipe left")
        handleSwipe(forDirection: .left)
    }
    
    func handleSwipeRight(_ recognizer: UITapGestureRecognizer) {
        print("Swipe right")
        handleSwipe(forDirection: .right)
    }
    
    enum SwipeDirection {
        case left
        case right
    }
    
    func handleSwipe(forDirection: SwipeDirection) {
        let tempFrame = self.scrollView.frame
        var newImageIndex = index
        var xOffset = 0;
        
        if forDirection == .left {
            xOffset = Int( self.scrollView.frame.width);
            newImageIndex += 1
        } else {
            xOffset = Int(-self.scrollView.frame.width);
            newImageIndex -= 1
        }
        
        let lastPhotoIndex = (photoManager?.count)! - 1
        if (newImageIndex < 0) {
            newImageIndex = lastPhotoIndex
        } else if (newImageIndex > lastPhotoIndex) {
            newImageIndex = 0
        }
        
        let image = (photoManager?.getPhotoImage(at: newImageIndex))!
        let newImageView = PhotoDetailsViewController.createImageView(withImage: image)
        let newScrollView = PhotoDetailsViewController.createScrollView(inParentView: self.view,
                                                                        forImageView: newImageView,
                                                                        withDelegate: self)
        
        view.addSubview(newScrollView)

        PhotoDetailsViewController.framePhoto(inScrollView: newScrollView,
                                              inImageView: newImageView,
                                              inFullscreen: self.isFullscreen)
        
        //newScrollView.bounds.origin.x = CGFloat(xOffset)
        
        let newImageName = photoManager?.getPhotoName(at: newImageIndex)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
            newScrollView.frame = tempFrame
        }) { (finished) in
            self.scrollView.removeFromSuperview()
            self.scrollView = newScrollView
            self.imageView = newImageView
            self.index = newImageIndex
            self.title = newImageName
        }
    }
    
    //MARK: - Tab bar hiding
    func setTabBarVisible(visible:Bool, animated:Bool) {
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
        PhotoDetailsViewController.centreImage(forScrollView: self.scrollView,
                                               forImageView: self.imageView,
                                               inFullscreen: navigationController?.isNavigationBarHidden == true)
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
