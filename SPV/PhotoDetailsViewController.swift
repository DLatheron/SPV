//
//  PhotoDetailsViewController.swift
//  SPV
//
//  Created by David Latheron on 06/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit
import Cosmos

protocol MediaEnumerator: class {
    func nextMedia(media: Media) -> Media
    func prevMedia(media: Media) -> Media
}

class PhotoDetailsViewController : UIViewController, Fullscreen {
    let showRatingsAnimationDuration = 0.2
    let hideRatingsAnimationDuration = 0.2
    
    var delegate: MediaEnumerator?
    var scrollView: PhotoScrollView?
    
    var media: Media! = nil
    var image: UIImage! = nil
    
    var singleTap: UITapGestureRecognizer? = nil
    var doubleTap: UITapGestureRecognizer? = nil
    var swipeLeft: UISwipeGestureRecognizer? = nil
    var swipeRight: UISwipeGestureRecognizer? = nil
    
    @IBOutlet weak var ratingsView: RatingsView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.isUserInteractionEnabled = true
        self.view.subviews.forEach { view in
            view.isUserInteractionEnabled = true
        }
        
        ratingsView.media = media
        enableRatingsView(true)
        
        self.view.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin, .flexibleWidth, .flexibleHeight]

        let infoButton = UIButton.init(type: .infoLight)
        infoButton.addTarget(self, action: #selector(showInfo), for: UIControlEvents.touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        navigationItem.rightBarButtonItem = barButton
        
        navigationController?.isNavigationBarHidden = false // This????
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        animateOnToScreen(forMedia: media)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupGestureRecognizers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeGestureRecognizers()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size,
                                 with: coordinator)

        let currentState = navigationController?.isNavigationBarHidden == false
        setTabBarVisible(visible: currentState, animated: false)

        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            self.scrollView?.centreImage()
            self.scrollView?.calcZoomScale()
            self.setTabBarVisible(visible: currentState, animated: false)
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.scrollView?.centreImage()
            self.scrollView?.calcZoomScale()
            self.setTabBarVisible(visible: currentState, animated: false)
        }
    }
    
    var isFullscreen: Bool {
        get {
            return navigationController?.isNavigationBarHidden == true
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return isFullscreen || !UIScreen.main.isLandscape
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
        print("Single Tap")
        // MAKE THIS NOT HAPPEN IF WE ARE INTERACTING WITH RATINGS...
        
        let currentState = navigationController?.isNavigationBarHidden == false
            
        navigationController?.setNavigationBarHidden(currentState, animated: true)
        setTabBarVisible(visible: !currentState, animated: true)
        
        // TODO: Would be best to do this AFTER the animation, or all in one
        scrollView!.centreImage()
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        print("Double Tap")
        
        // TODO: Also zoom into the point tapped...
        // TODO: Multistage zoom - based on the size of the picture... no more than about 3 stages...
        // TODO: Move into PhotoScrollView
        if self.scrollView!.zoomScale > self.scrollView!.minimumZoomScale {
            self.scrollView!.setZoomScale(self.scrollView!.minimumZoomScale, animated: true)
            enableRatingsView(true)
        } else {
            self.scrollView!.setZoomScale()
            self.scrollView!.setZoomScale(self.scrollView!.maximumZoomScale, animated: true)
            enableRatingsView(false)
        }
    }

    @objc func handleSwipeLeft(_ recognizer: UISwipeGestureRecognizer) {
        print("Swipe left")
        handleSwipe(forDirection: .left)
    }
    
    @objc func handleSwipeRight(_ recognizer: UISwipeGestureRecognizer) {
        print("Swipe right")
        handleSwipe(forDirection: .right)
    }
    
    enum SwipeDirection {
        case left
        case right
    }
    
    func animateOnToScreen(forMedia newMedia: Media,
                           from xOffset: CGFloat = 0.0,
                           over duration: TimeInterval = 0.0) {
        let image = newMedia.getImage()
        let newScrollView = PhotoScrollView(parentView: self.view,
                                            forImage: image,
                                            fullscreen: self)
        newScrollView.center.x += xOffset
        self.view.addSubview(newScrollView)
        self.view.bringSubview(toFront: self.ratingsView)
        
        newScrollView.setNeedsLayout()
        newScrollView.setNeedsDisplay()
        
        let newImageName = newMedia.filename
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.0,
                       options: .curveEaseOut,
                       animations: {
                        newScrollView.center.x -= xOffset
        }) { (finished) in
            if (finished) {
                self.scrollView?.removeFromSuperview()
                self.scrollView = newScrollView
                self.media = newMedia
                self.title = newImageName
            }
        }
    }
    
    func handleSwipe(forDirection: SwipeDirection) {
        var newMedia: Media
        var xOffset: CGFloat = 0
        
        if forDirection == .left {
            xOffset = CGFloat(self.scrollView!.frame.width)
            newMedia = (delegate?.nextMedia(media: media!))!
        } else {
            xOffset = CGFloat(-self.scrollView!.frame.width)
            newMedia = (delegate?.prevMedia(media: media!))!
        }
        
        animateOnToScreen(forMedia: newMedia,
                          from: xOffset,
                          over: 0.3)
    }
    
    //MARK: - Tab bar hiding
    func setTabBarVisible(visible:Bool,
                          animated:Bool) {
        if (tabBarIsVisible() == visible) { return }
        
        let bar = self.tabBarController!.tabBar
        
        let frame = bar.frame
        let height = frame.size.height
        let onScreenCentreY = UIScreen.main.bounds.height - height / 2
        let offScreenCentreY = UIScreen.main.bounds.height + height / 2
        let duration = (animated ? 0.3 : 0.0)
        
        if (visible) {
            bar.isHidden = false
            bar.center.y = offScreenCentreY
            UIView.animate(withDuration: duration,
                           animations: {
                bar.center.y = onScreenCentreY
            })
        } else {
            bar.center.y = onScreenCentreY
            UIView.animate(withDuration: duration,
                           animations: {
                bar.center.y = offScreenCentreY
            }, completion: { (completed) in
                if completed {
                    bar.isHidden = true
                }
            })
        }
    }
    
    func tabBarIsVisible() -> Bool {
        return !self.tabBarController!.tabBar.isHidden
    }
    
    func enableRatingsView(_ enable: Bool) {
        ratingsView.isUserInteractionEnabled = enable
    }
}
