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

class PhotoDetailsViewController : UIViewController, PhotoScrollViewDelegate, Rotatable {
    let showRatingsAnimationDuration = 0.2
    let hideRatingsAnimationDuration = 0.2
    
    var delegate: MediaEnumerator?
    
    var embeddedMediaView: EmbeddedMediaViewDelegate?
    
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
        
        media.wasViewed()
        
        ratingsView.media = media
        ratingsView.delegate = self
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
        
        enableRatingsView(true)
        
        animateOnToScreen(forMedia: media)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIViewController.attemptRotationToDeviceOrientation()
        
        setupGestureRecognizers()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        removeGestureRecognizers()

        if (self.isMovingFromParentViewController) {
            resetToPortrait()
        }
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size,
                                 with: coordinator)

        let currentState = navigationController?.isNavigationBarHidden == false
        setTabBarVisible(visible: currentState, animated: false)

        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            self.embeddedMediaView?.willRotate(parentView: self.view)
            
            self.setTabBarVisible(visible: currentState,
                                  animated: false)
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.embeddedMediaView?.didRotate(parentView: self.view)
            
            self.setTabBarVisible(visible: currentState,
                                  animated: false)
        }
    }
    
    var isFullscreen: Bool {
        get {
            return navigationController?.isNavigationBarHidden == true
        }
    }
    
    var isFullyZoomedOut: Bool {
        get {
            return embeddedMediaView?.isFullyZoomedOut ?? true
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
        doubleTap?.delegate = self
        self.view.addGestureRecognizer(doubleTap!)
        self.view.addGestureRecognizer(singleTap!)
        
        singleTap?.require(toFail: doubleTap!)

        // Swipe left for next image.
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
        swipeLeft?.direction = UISwipeGestureRecognizerDirection.left
        swipeLeft?.delegate = self
        self.view.addGestureRecognizer(swipeLeft!)
        
        // Swipe right for previous image.
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
        swipeRight?.direction = UISwipeGestureRecognizerDirection.right
        swipeRight?.delegate = self
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
        
        if ratingsView.alpha > 0 {
            recognizer.cancel()
            let hitView = ratingsView.hitTest(recognizer.location(in: self.view),
                                              with: nil)
            self.ratingsView.hide(cancelled: hitView == self.ratingsView)
            return
        }
        
        let currentState = navigationController?.isNavigationBarHidden == false
        
        navigationController?.setNavigationBarHidden(currentState, animated: true)
        setTabBarVisible(visible: !currentState, animated: true)
        
        // TODO: Would be best to do this AFTER the animation, or all in one
        embeddedMediaView?.singleTap()
    }
    
    @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
        print("Double Tap")
        
        // TODO: Also zoom into the point tapped...
        // TODO: Multistage zoom - based on the size of the picture... no more than about 3 stages...
        // TODO: Move into PhotoScrollView
        embeddedMediaView?.doubleTap()
        
        enableRatingsView(embeddedMediaView?.isFullyZoomedOut ?? true)
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
        func displayNewMediaView(view: UIView,
                                 delegate: EmbeddedMediaViewDelegate) {
            view.center.x += xOffset
            self.view.addSubview(view)
            self.view.bringSubview(toFront: self.ratingsView)
            
            view.setNeedsLayout()
            view.setNeedsDisplay()
            
            let newImageName = newMedia.filename
            
            UIView.animate(withDuration: 0.3,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations:
                {
                    view.center.x -= xOffset
                })
            { (finished) in
                if (finished) {
                    self.embeddedMediaView?.remove()
                    self.embeddedMediaView = delegate
                    self.media = newMedia
                    self.ratingsView.media = newMedia
                    self.title = newImageName
                    
                    self.ratingsView.beginPreview()
                }
            }
        }
        
        ratingsView.endPreview()
        
        // TODO: If the old view is a videoView then we need to remove it from the superview...
        let newView: UIView
        
        switch newMedia.mediaExtension.type {
        case MediaType.photo:
            let image = newMedia.getImage()
            newView = PhotoScrollView(parentView: self.view,
                                      forImage: image,
                                      psvDelegate: self)
            
        case MediaType.livePhoto:
            newView = LivePhotoScrollView(parentView: self.view,
                                          forLivePhoto: newMedia as! LivePhoto,
                                          psvDelegate: self)
            
        case MediaType.video:
            newView = VideoView(parentController: self,
                                forMedia: newMedia)
        }
        
        displayNewMediaView(view: newView,
                            delegate: newView as! EmbeddedMediaViewDelegate)
    }
    
    func handleSwipe(forDirection: SwipeDirection) {
        var newMedia: Media
        var xOffset: CGFloat = 0
        
        if let embeddedView = embeddedMediaView?.view {
            if forDirection == .left {
                xOffset = CGFloat(embeddedView.frame.width)
                newMedia = (delegate?.nextMedia(media: media!))!
            } else {
                xOffset = CGFloat(-embeddedView.frame.width)
                newMedia = (delegate?.prevMedia(media: media!))!
            }
            
            animateOnToScreen(forMedia: newMedia,
                              from: xOffset,
                              over: 0.3)
            
            newMedia.wasViewed()
        }
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
        let enable = enable && Settings.shared.quickRating.value
        ratingsView.isUserInteractionEnabled = enable
    }
}

extension PhotoDetailsViewController : UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return !ratingsView.shouldSuppressGestures
    }
}

extension PhotoDetailsViewController : RatingsViewDelegate {
    func canBeginInteraction() -> Bool {
        return isFullyZoomedOut
    }
}
