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

class RatingsView : UIView {
    let minViewAlpha: CGFloat = 0.0
    let maxViewAlpha: CGFloat = 1.0
    let viewFadeOutDuration: TimeInterval = 0.2
    let viewFadeInDuration: TimeInterval = 0.2
    
    var cosmosView: CosmosView! = nil
    var media: Media? = nil {
        didSet {
            if let media = media {
                cosmosView.rating = Double(media.mediaInfo.rating)
                cosmosView.didFinishTouchingCosmos = {
                    print("Rating updated to \($0)")
                    media.mediaInfo.rating = Int($0)
                    media.save()
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
        show()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>,
                               with event: UIEvent?) {
        hide()
    }
    
    override func hitTest(_ point: CGPoint,
                          with event: UIEvent?) -> UIView? {
        return cosmosView.hitTest(point,
                                  with: event)
    }
    
    func show() {
        UIView.animate(withDuration: viewFadeInDuration,
                       animations: {
            self.alpha = self.maxViewAlpha
        })
    }
    
    func hide() {
        UIView.animate(withDuration: viewFadeOutDuration,
                       animations: {
            self.alpha = self.minViewAlpha
        })
    }
}
