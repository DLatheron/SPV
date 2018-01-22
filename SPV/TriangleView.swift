//
//  TriangleView.swift
//  SPV
//
//  Created by dlatheron on 19/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class TriangleView : UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let points = [
            CGPoint(x: rect.minX, y: rect.minY),
            CGPoint(x: rect.maxX, y: (rect.maxY / 2.0)),
            CGPoint(x: rect.minX, y: rect.maxY)
        ]
        
        drawTriangle(context,
                     withPoints: points,
                     fillColour: UIColor.white,
                     strokeColour: UIColor.black)
    }
    
    func drawTriangle(_ context: CGContext,
                      withPoints points: [CGPoint],
                      fillColour: UIColor,
                      strokeColour: UIColor) {
        func drawPath() {
            context.beginPath()
            context.move(to: points[0])
            context.addLine(to: points[1])
            context.addLine(to: points[2])
            context.closePath()
        }

        drawPath()
        context.setFillColor(fillColour.cgColor)
        context.fillPath()
        
        drawPath()
        context.setStrokeColor(strokeColour.cgColor)
        context.setLineWidth(1.0)
        context.setLineJoin(.miter)
        context.strokePath()
    }
}
