
//
//  RangeSliderThumbLayer.swift
//  Flip
//
//  Created by Jozef Matus on 06/01/16.
//  Copyright © 2016 STRV. All rights reserved.
//

import UIKit
import QuartzCore

class RangeSliderThumbLayer: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var rangeSlider: RangeSlider?
    
    override func drawInContext(ctx: CGContext!) {
        if let slider = rangeSlider {
            
            //bigger circle
            let thumbFrame = CGRect(x: bounds.origin.x + 1, y: bounds.origin.y + 1, width: bounds.height - 2, height: bounds.height - 2)
            let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
            let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
            
            //smaller circle
            let smallerCircleFrame = thumbFrame.insetBy(dx: 6.0, dy: 6.0)
            let smallerCirclePath = UIBezierPath(roundedRect: smallerCircleFrame, cornerRadius: cornerRadius)
            
            // Fill - with a subtle shadow
            let shadowColor = UIColor.lightGrayColor()
            
            CGContextSetShadowWithColor(ctx, CGSize(width: 0.0, height: 0.5), 2.0, shadowColor.CGColor)
            CGContextSetFillColorWithColor(ctx, UIColor.whiteColor().CGColor)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextFillPath(ctx)
            
            CGContextSetFillColorWithColor(ctx, slider.thumbTintColor.CGColor)
            CGContextAddPath(ctx, smallerCirclePath.CGPath)
            CGContextFillPath(ctx)

            // Outline
            CGContextSetStrokeColorWithColor(ctx, shadowColor.CGColor)
            CGContextSetLineWidth(ctx, 0.5)
            CGContextAddPath(ctx, thumbPath.CGPath)
            CGContextStrokePath(ctx)
            
            if highlighted {
                CGContextSetFillColorWithColor(ctx, UIColor(white: 0.0, alpha: 0.1).CGColor)
                CGContextAddPath(ctx, thumbPath.CGPath)
                CGContextFillPath(ctx)
            }
        }
    }
    
}