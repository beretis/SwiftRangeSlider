//
//  RangeSlider.swift
//  Flip
//
//  Created by Jozef Matus on 06/01/16.
//  Copyright © 2016 STRV. All rights reserved.
//

import UIKit

class RangeSlider: UIControl {


    var increase: Double = 1

    var numberOfValues: Int {
        return Int((maximumValue - minimumValue) / increase)
    }

    var step: CGFloat {
        return bounds.width / CGFloat(numberOfValues)
    }

    var minimumValue: Double = 0 {
        didSet {
            updateLayerFrames()
        }
    }

    var maximumValue: Double = 100 {
        didSet {
            updateLayerFrames()
        }
    }

    var lowerValue: Double = 0 {
        didSet {
            updateLayerFrames()
        }
    }

    var upperValue: Double = 0 {
        didSet {
            updateLayerFrames()
        }
    }

    var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    var thumbTintColor: UIColor = UIColor.whiteColor() {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }

    var curvaceousness: CGFloat = 1.0 {
        didSet {
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }

    var minMaxLabelFont: UIFont = UIFont.systemFontOfSize(13) {
        didSet {
            updateLayerFrames()
        }
    }

    var minMaxLabelTextColor: UIColor = UIColor.blackColor() {
        didSet {
            updateLayerFrames()
        }
    }

    var valueLabelFont: UIFont = UIFont.systemFontOfSize(13) {
        didSet {
            updateLayerFrames()
        }
    }

    var valueLabelTextColor: UIColor = UIColor.blackColor() {
        didSet {
            updateLayerFrames()
        }
    }

    var trackThickness: CGFloat = CGFloat(3) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    let trackLayer = RangeSliderTrackLayer()
    let lowerThumbLayer = RangeSliderThumbLayer()
    let upperThumbLayer = RangeSliderThumbLayer()
    var previousLocation = CGPoint()
    var minimumLabel: UILabel = UILabel()
    var maximumLabel: UILabel = UILabel()
    var lowerLabel: UILabel = UILabel()
    var upperLabel: UILabel = UILabel()

    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }

    var thumbWidth: CGFloat {
        return CGFloat(30)
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayerFrames()
    }

    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)

        // Hit test the thumb layers
        if lowerThumbLayer.frame.contains(previousLocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previousLocation) {
            upperThumbLayer.highlighted = true
        }

        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted
    }

    
    
    
    private func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }

    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        let value = round(location.x / step)
        let validValue = minimumValue + (Double(value) * increase)
        let deltaLocation = Double(location.x - previousLocation.x)
        previousLocation = location

        //when indicators are on the same position, we select highlighted based on movement
        if lowerThumbLayer.frame.origin == upperThumbLayer.frame.origin {
            if deltaLocation < 0 {
                //left
                lowerThumbLayer.highlighted = true
                upperThumbLayer.highlighted = false
            } else if deltaLocation > 0 {
                //right
                lowerThumbLayer.highlighted = false
                upperThumbLayer.highlighted = true
            }
        }
        // 2. Update the values
        if lowerThumbLayer.highlighted {
            lowerValue = boundValue(validValue, toLowerValue: minimumValue, upperValue: upperValue)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(validValue, toLowerValue: lowerValue, upperValue: maximumValue)
        }


        return true
    }

    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false

        sendActionsForControlEvents(.ValueChanged)
    }

    //Mark: Private
    
    private func setup() {
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(upperThumbLayer)
        
        //add labels to view
        addSubview(minimumLabel)
        addSubview(maximumLabel)
        addSubview(lowerLabel)
        addSubview(upperLabel)
        
        upperValue = maximumValue
        lowerValue = minimumValue
    }
    
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        //draw line
        trackLayer.frame = CGRect(x: bounds.origin.x, y: bounds.height / 2, width: bounds.width, height: 3)
        trackLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: trackLayer.frame.midY - thumbWidth / 2,
            width: thumbWidth, height: thumbWidth)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth / 2.0, y: trackLayer.frame.midY - thumbWidth / 2,
            width: thumbWidth, height: thumbWidth)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
        
        minimumLabel.frame = CGRect(x: trackLayer.bounds.minX, y: lowerThumbLayer.frame.maxY, width: 40, height: 20)
        maximumLabel.frame = CGRect(x: trackLayer.bounds.maxX - 40, y: lowerThumbLayer.frame.maxY, width: 40, height: 20)
        
        lowerLabel.frame = CGRect(x: lowerThumbLayer.frame.midX - 17.5, y: lowerThumbLayer.frame.minY - 20, width: 35, height: 20)
        upperLabel.frame = CGRect(x: upperThumbLayer.frame.midX - 17.5, y: lowerThumbLayer.frame.minY - 20, width: 35, height: 20)
        
        if upperLabel.frame.contains(CGPoint(x: lowerLabel.frame.maxX, y: lowerLabel.frame.midY)) {
            let movement = abs(lowerLabel.frame.maxX - upperLabel.frame.minX) / 2
            upperLabel.frame.offsetInPlace(dx: movement, dy: 0)
            lowerLabel.frame.offsetInPlace(dx: -movement, dy: 0)
        }
        
        minimumLabel.text = String(minimumValue)
        maximumLabel.text = String(maximumValue)
        lowerLabel.text = String(lowerValue)
        upperLabel.text = String(upperValue)
        setupLabels()
        
    }

    private func setupLabels() {
        upperLabel.font = valueLabelFont
        lowerLabel.font = valueLabelFont
        upperLabel.textColor = valueLabelTextColor
        lowerLabel.textColor = valueLabelTextColor
        lowerLabel.textAlignment = NSTextAlignment.Center
        upperLabel.textAlignment = NSTextAlignment.Center
        maximumLabel.textAlignment = NSTextAlignment.Right

        maximumLabel.font = minMaxLabelFont
        minimumLabel.font = minMaxLabelFont
        maximumLabel.textColor = minMaxLabelTextColor
        minimumLabel.textColor = minMaxLabelTextColor
    }


    //Mark: Public
    func resetCurrentValues() {
        upperValue = maximumValue
        lowerValue = minimumValue
    }

    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) /
                (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }

}
