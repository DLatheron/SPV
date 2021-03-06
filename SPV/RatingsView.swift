//
//  RatingsView.swift
//  SPV
//
//  Created by dlatheron on 10/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import Cosmos
import UIKit

protocol RatingsViewDelegate {
    func canBeginInteraction() -> Bool
}

class RatingsView : UIView {
    fileprivate let minViewAlpha: CGFloat = 0.0
    fileprivate let maxViewAlpha: CGFloat = 1.0
    fileprivate let interactionBeganFadeDuration: TimeInterval = 0.3
    fileprivate let interactionEndedFadeDuration: TimeInterval = 0.3
    fileprivate let interactionCancelledFadeDuration: TimeInterval = 0.5
    fileprivate let previewDuration: TimeInterval = 1.0
    
    fileprivate var interacting = false
    fileprivate var cancelled = false
    fileprivate var previewing = false
    
    fileprivate var cosmosView: CosmosView! = nil
    fileprivate var backgroundView: CosmosView! = nil

    var delegate: RatingsViewDelegate? = nil
    var media: Media? = nil {
        didSet {
            let rating: Double
            if let media = media {
                rating = Double(media.mediaInfo.rating)
                
                cosmosView.didFinishTouchingCosmos = {
                    if self.cancelled {
                        print("Rating update was cancelled")
                    } else {
                        print("Rating updated to \($0)")
                        media.mediaInfo.rating = Int($0)
                        media.save()
                    }
                }
            } else {
                rating = 0
            }
            
            cosmosView.rating = rating
            backgroundView.rating = rating
        }
    }
    var shouldSuppressGestures: Bool {
        get {
            return alpha > 0 && !previewing
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let visualEffectView = self.subviews[0] as! UIVisualEffectView
        let contentSubViews = visualEffectView.contentView.subviews
        
        backgroundView = contentSubViews[0] as! CosmosView
        cosmosView = contentSubViews[1] as! CosmosView

        alpha = minViewAlpha
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        previewing = false
        
        if delegate?.canBeginInteraction() ?? false {
            show()
        } else {
            super.touchesBegan(touches,
                               with: event)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        let xThreshold: CGFloat = 44
        let yThreshold: CGFloat = 44
        
        let location = touches.first!.location(in: self)
        if location.x < bounds.minX - xThreshold
            || location.x > bounds.maxX + xThreshold
            || location.y < bounds.minY - yThreshold
            || location.y > bounds.maxY + yThreshold {
            hide(cancelled: true)
        } else {
            super.touchesMoved(touches,
                               with: event)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        hide()

        super.touchesEnded(touches,
                           with: event)
    }
    
    override func hitTest(_ point: CGPoint,
                          with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled {
            return nil
        }

        return cosmosView.hitTest(point,
                                  with: event)
    }
    
    fileprivate func cosmosTouchEvents(enabled: Bool) {
        cosmosView.setValue(enabled,
                            forKey: "updateOnTouch")
    }
    
    fileprivate func interactionBegan() {
        interacting = true
        cancelled = false
        cosmosTouchEvents(enabled: true)
    }
    
    fileprivate func updateMediaRating(rating: Int?) {
        if let media = media {
            if let rating = rating {
                cosmosView.rating = Double(rating)
                backgroundView.rating = Double(rating)
                cosmosView.update()
                backgroundView.update()
                
                print("Rating updated to \(rating)")
                media.mediaInfo.rating = rating
                media.save()
            } else {
                cosmosView.rating = Double(media.mediaInfo.rating)
                backgroundView.rating = Double(media.mediaInfo.rating)
                cosmosView.update()
                backgroundView.update()
            }
        }
    }
    
    fileprivate func interactionEnded(wasCancelledOrNoChange: Bool) -> Bool {
        interacting = false
        cancelled = wasCancelledOrNoChange
        
        if cancelled {
            cosmosView.didFinishTouchingCosmos = nil
            self.updateMediaRating(rating: nil)
        } else {
            cosmosView.didFinishTouchingCosmos = {
                self.updateMediaRating(rating: Int($0))
            }
        }
        cosmosTouchEvents(enabled: false)
        
        return cancelled
    }
    
    fileprivate func show() {
        if !interacting {
            transform = CGAffineTransform(scaleX: 1,
                                          y: 1)

            UIView.animate(withDuration: interactionBeganFadeDuration,
                           delay: 0.0,
                           options: .beginFromCurrentState,
                           animations: {
                self.alpha = self.maxViewAlpha
            }) { complete in
                if complete {
                    self.interactionBegan()
                }
            }
        } else {
            self.interactionBegan()
        }
    }
    
    func hide(cancelled wasCancelled: Bool = false) {
        let noChange = media?.mediaInfo.rating == Int(cosmosView.rating)
        
        if interactionEnded(wasCancelledOrNoChange: wasCancelled || noChange) {
            UIView.animate(withDuration: interactionCancelledFadeDuration,
                           delay: 0.0,
                           options: .beginFromCurrentState,
                           animations: {
                            self.alpha = self.minViewAlpha
            })
        } else {
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 6,
                           options: [.curveEaseInOut, .beginFromCurrentState],
                           animations: {
                self.transform = CGAffineTransform(scaleX: 1.1,
                                                   y: 1.1)
            }, completion: { completion in
                UIView.animate(withDuration: self.interactionEndedFadeDuration,
                               animations: {
                    self.alpha = self.minViewAlpha
                })
            })
        }
    }
    
    func beginPreview() {
        previewing = true
        
        self.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + previewDuration) {
            self.endPreview()
        }
    }
    
    func endPreview() {
        if self.previewing {
            self.previewing = false
            hide(cancelled: true)
        }
    }
}
