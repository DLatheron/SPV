//
//  Interpolator.swift
//  SPV
//
//  Created by dlatheron on 27/02/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class Interpolator {
    static func interpolate(from fromValue: CGFloat,
                            to toValue: CGFloat,
                            withProgress progress: CGFloat,
                            minProgress: CGFloat = 0.0,
                            maxProgress: CGFloat = 1.0) -> CGFloat {
        let rangeProgress = (progress - minProgress) / (maxProgress - minProgress)
        let clampedProgress = max(min(rangeProgress, 1), 0)
        
        return fromValue - ((fromValue - toValue) * clampedProgress)
    }
}
