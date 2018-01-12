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
    func interactionBegan()
    func interactionEnded()
    func interactionCancelled()
}

class RatingsView : UIView {
    let minViewAlpha: CGFloat = 0.0
    let maxViewAlpha: CGFloat = 1.0
    let viewFadeOutDuration: TimeInterval = 0.3
    let viewFadeInDuration: TimeInterval = 0.3
    
    var delegate: RatingsViewDelegate? = nil
    var interacting = false
    var cancelled = false
    
    var cosmosView: CosmosView! = nil
    var media: Media? = nil {
        didSet {
            if let media = media {
                cosmosView.rating = Double(media.mediaInfo.rating)
                cosmosView.didFinishTouchingCosmos = {
                    if self.cancelled {
                        print("Rating update was cancelled")
                    } else {
                        print("Rating updated to \($0)")
                        media.mediaInfo.rating = Int($0)
                        media.save()
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let visualEffectView = self.subviews[0] as! UIVisualEffectView
        cosmosView = visualEffectView.contentView.subviews[0] as! CosmosView

        alpha = minViewAlpha
    }
    
    override func touchesBegan(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
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
        print("Location: \(location)")
        if location.x < bounds.minX - xThreshold
            || location.x > bounds.maxX + xThreshold
            || location.y < bounds.minY - yThreshold
            || location.y > bounds.maxY + yThreshold {
            cancel()
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
        print("Testing")
        return cosmosView.hitTest(point,
                                  with: event)
    }
    
    func cosmosTouchEvents(enabled: Bool) {
        cosmosView.setValue(enabled,
                            forKey: "updateOnTouch")
    }
    
    func interactionBegan() {
        interacting = true
        cancelled = false
        delegate?.interactionBegan()
        cosmosTouchEvents(enabled: true)
    }
    
    func interactionEnded() {
        interacting = false
        if cancelled {
            delegate?.interactionCancelled()
        } else {
            delegate?.interactionEnded()
        }
        cosmosTouchEvents(enabled: false)
    }
    
    func show() {
        if !interacting {
            transform = CGAffineTransform(scaleX: 1,
                                          y: 1)

            UIView.animate(withDuration: viewFadeInDuration,
                           animations: {
                self.alpha = self.maxViewAlpha
            }) { complete in
                if complete {
                    self.interactionBegan()
                }
            }
        }
    }
    
    func hide() {
        if interacting {
            interactionEnded()
            
            UIView.animate(withDuration: 0.5,
                           delay: 0.0,
                           usingSpringWithDamping: 0.1,
                           initialSpringVelocity: 6,
                           options: [.curveEaseInOut],
                           animations: {
                self.transform = CGAffineTransform(scaleX: 1.1,
                                                   y: 1.1)
            }, completion: { completion in
                UIView.animate(withDuration: self.viewFadeOutDuration,
                               animations: {
                    self.alpha = self.minViewAlpha
                })
            })
            
//            UIView.animate(withDuration: 0.1,
//                           delay: 0,
//                           options: [.repeat, .autoreverse],
//                           animations: {
//                UIView.setAnimationRepeatCount(2)
//                self.transform = CGAffineTransform(scaleX: 1.2,
//                                                   y: 1.2)
//            }, completion: { completion in
//                self.transform = CGAffineTransform(scaleX: 1,
//                                                   y: 1)
//                UIView.animate(withDuration: self.viewFadeOutDuration,
//                               animations: {
//                    self.alpha = self.minViewAlpha
//                })
//            })
        }
    }
    
    func cancel() {
        if interacting {
            cancelled = true
            
            interactionEnded()
            
            if let media = media {
                cosmosView.rating = Double(media.mediaInfo.rating)
                cosmosView.update()
            }
            
            UIView.animate(withDuration: viewFadeOutDuration,
                           animations: {
                self.alpha = self.minViewAlpha
            })
        }
    }
}
