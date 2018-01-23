//
//  VideoView.swift
//  SPV
//
//  Created by dlatheron on 22/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import AVKit

class VideoView : UIView {
    var media: Media
    var player: AVPlayerLooper!
    var avpController = AVPlayerViewController()
    
    init(parentController: UIViewController,
         forMedia media: Media) {
        self.media = media
        
        let queuePlayer = AVQueuePlayer()
        //let playerLayer = AVPlayerLayer(player: player)
        let playerItem = AVPlayerItem(url: media.fileURL)
        player = AVPlayerLooper(player: queuePlayer,
                                templateItem: playerItem)
        avpController = AVPlayerViewController()
        avpController.entersFullScreenWhenPlaybackBegins = true
        avpController.exitsFullScreenWhenPlaybackEnds = true

        super.init(frame: UIScreen.main.bounds)

        avpController.player = queuePlayer
        avpController.view.frame = frame
        parentController.addChildViewController(avpController)
        addSubview(avpController.view)
        
        player.addObserver(self,
                           forKeyPath: #keyPath(AVPlayer.status),
                           options: [.new],
                           context: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        if keyPath == #keyPath(AVPlayer.status) {
            let status = player.status
            print("AVPlayer Status: \(status)")
        }
    }
}

extension VideoView : EmbeddedMediaViewDelegate {
    var isFullyZoomedOut: Bool {
        get {
            return true
        }
    }
    
    var view: UIView {
        get {
            return self
        }
    }
    
    func willRotate(parentView: UIView) {
        center = parentView.center
        bounds = parentView.bounds
    }
    
    func didRotate(parentView: UIView) {
    }
    
    func remove() {
        avpController.removeFromParentViewController()
        removeFromSuperview()
    }
    
    func singleTap() {
        // Intentionally left blank.
    }
    
    func doubleTap() {
        // Intentionally left blank.
    }
}
