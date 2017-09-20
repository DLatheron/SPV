//
//  PhotoDetailsViewController.swift
//  SPV
//
//  Created by David Latheron on 06/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol MediaEnumerator: class {
    func nextMedia(media: Media) -> Media
    func prevMedia(media: Media) -> Media
}

class PhotoDetailsViewController : UIViewController, Fullscreen {
    var scrollView: PhotoScrollView!
    var delegate: MediaEnumerator?
    
    var media: Media? = nil
    var image: UIImage! = nil
    
    var singleTap: UITapGestureRecognizer? = nil
    var doubleTap: UITapGestureRecognizer? = nil
    var swipeLeft: UISwipeGestureRecognizer? = nil
    var swipeRight: UISwipeGestureRecognizer? = nil
    
    @IBOutlet var imageScrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = self.image
        imageView.sizeToFit()
        
        centreImage()
        setZoomScale()
        
        title = media?.filename

        let infoButton = UIButton.init(type: .infoLight)
        infoButton.addTarget(self, action: #selector(showInfo), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = barButton
        
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showInfo))
        
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupGestureRecognizers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeGestureRecognizers()
    }
    
    override func viewWillLayoutSubviews() {
//        scrollView.framePhoto()
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
    
    override func prepare(for segue: UIStoryboardSegue,
                          sender: Any!) {
        if (segue.identifier == "MediaInfo") {
            let media = sender as! Media
            let mediaInfoVC = segue.destination as? MediaInfoViewController
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            mediaInfoVC?.media = media
        }
    }

    @objc func showInfo() {
        self.performSegue(withIdentifier: "MediaInfo",
                          sender: media!)
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
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        let currentState = navigationController?.isNavigationBarHidden == false
        
        navigationController?.setNavigationBarHidden(currentState, animated: true)
        setTabBarVisible(visible: !currentState, animated: true)
        
        centreImage()
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        // TODO: Also zoom into the point tapped...
        // TODO: Multistage zoom - based on the size of the picture... no more than about 3 stages...
        // TODO: Move into PhotoScrollView
        if (self.imageScrollView.zoomScale > self.imageScrollView.minimumZoomScale) {
            self.imageScrollView.setZoomScale(self.imageScrollView.minimumZoomScale, animated: true)
        } else {
            self.imageScrollView.setZoomScale(self.imageScrollView.maximumZoomScale, animated: true)
        }
    }
    
    @objc func handleSwipeLeft(_ recognizer: UITapGestureRecognizer) {
        print("Swipe left")
        handleSwipe(forDirection: .left)
    }
    
    @objc func handleSwipeRight(_ recognizer: UITapGestureRecognizer) {
        print("Swipe right")
        handleSwipe(forDirection: .right)
    }
    
    enum SwipeDirection {
        case left
        case right
    }
    
    func handleSwipe(forDirection: SwipeDirection) {
        var newMedia: Media
        var xOffset: CGFloat = 0
        
        if forDirection == .left {
            xOffset = CGFloat(self.scrollView.frame.width);
            newMedia = (delegate?.nextMedia(media: media!))!
        } else {
            xOffset = CGFloat(-self.scrollView.frame.width);
            newMedia = (delegate?.prevMedia(media: media!))!
        }
        
        let image = newMedia.getImage()
        let newScrollView = PhotoScrollView(parentView: self.view,
                                            forImage: image,
                                            fullscreen: self)
        newScrollView.center.x += xOffset
        
        newScrollView.setNeedsLayout()
        newScrollView.setNeedsDisplay()
    
        let newImageName = newMedia.filename
        
        UIView.animate(withDuration: 0.4,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
            newScrollView.center.x -= xOffset
        }) { (finished) in
            if (finished) {
                self.scrollView.removeFromSuperview()
                self.scrollView = newScrollView
                self.media = newMedia
                self.title = newImageName
            }
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
    
    func setZoomScale() {
        let imageViewSize = imageView.bounds.size
        let scrollViewSize = imageScrollView.bounds.size
        let widthScale = scrollViewSize.width / imageViewSize.width
        let heightScale = scrollViewSize.height / imageViewSize.height
        
        imageScrollView.minimumZoomScale = min(widthScale, heightScale)
        imageScrollView.zoomScale = min(widthScale, heightScale)
    }
    
    func centreImage() {
        let imageViewSize = imageView.frame.size
        let scrollViewSize = imageScrollView.frame.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        let bottomOffset = CGFloat(isFullscreen ? -50 : 0)
        
        imageScrollView.contentInset
            = UIEdgeInsets(top: verticalPadding,
                           left: horizontalPadding,
                           bottom: verticalPadding + bottomOffset,
                           right: horizontalPadding)
        
        imageScrollView.scrollIndicatorInsets
            = UIEdgeInsets(top: 0,
                           left: 0,
                           bottom: bottomOffset,
                           right: 0)
    }
}

extension PhotoDetailsViewController : UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centreImage()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        print("\(scrollView.contentInset)")
    }
}
