//
//  TimedAlertController.swift
//  SPV
//
//  Created by dlatheron on 01/12/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class TimedAlertController {
    fileprivate var alertController: UIAlertController!
    fileprivate var okAction: UIAlertAction!
    
    fileprivate var message: String {
        get {
            switch self.countdown {
            case 0:
                return "Click OK to retry"
            case 1:
                return "You can retry in \(countdown) second"
            default:
                return "You can retry in \(countdown) seconds"
            }
        }
    }

    fileprivate var countdown: Int = 5
    fileprivate var timer: Timer?
    
    init(reason: String,
         for countdown: Int,
         viewController: UIViewController,
         completionBlock: (() -> Void)?) {
        self.countdown = countdown
        
        alertController = UIAlertController(title: reason,
                                            message: message,
                                            preferredStyle: .alert)
        okAction = UIAlertAction(title: "OK",
                                 style: .default,
                                 handler:
            { alertAction in
                completionBlock?()
            }
        )
        
        alertController.addAction(okAction)

        if countdown == 0 {
            viewController.present(alertController,
                                   animated: true)
        } else {
            okAction.isEnabled = false
        
            viewController.present(alertController,
                                   animated: true) {
                self.timer = Timer.scheduledTimer(
                    withTimeInterval: 1,
                    repeats: true,
                    block:
                    { (timer) in
                        self.timerHandler()
                    }
                )
            }
        }
    }
    
    fileprivate func timerHandler() {
        countdown -= 1
        alertController.message = message
        
        if countdown == 0 {
            timeout()
        }
    }
    
    fileprivate func timeout() {
        okAction.isEnabled = true
        
        timer!.invalidate()
        timer = nil
    }
}
