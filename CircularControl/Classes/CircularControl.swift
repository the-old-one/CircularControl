//
//  CircularSlider.swift
//  CircularControl
//
//  Created by Oleg Chernyshenko on 20/06/17.
//  Copyright © 2017 tugboat. All rights reserved.
//

import UIKit

open class CircularControl: UIControl {

    /// default is 20
    open var lineWidth: CGFloat = 20
    open var radius: CGFloat = 50.0

    /// The color of the background circle. Default is black.
    open var trackColor = UIColor.black
    open var startColor = UIColor.red
    open var endColor =  UIColor.yellow
    /// Default 0.0. this value will be pinned to min/max
    open var value: Double {
        get { return _value }
        set { _value = min(maximumValue, max(minimumValue, newValue)) }
    }
    /// Default 0.0. the current value may change if outside new min value
    open var minimumValue: Double = 0.0
    /// Default 1.0. the current value may change if outside new max value
    open var maximumValue: Double = 1.0
    open var startAngle: Double = 0
    open var handleRadius: CGFloat = 10
    open var handleColor: UIColor = .white
    open var shadowBlur: CGFloat = 10

    private var _value: Double = 0.0

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    convenience public init(radius: CGFloat, lineWidth: CGFloat, margin: CGFloat = 20.0) {
        let sideLength = radius * 2 + lineWidth + margin
        self.init(frame: CGRect(x: 0, y: 0, width: sideLength, height: sideLength))
        self.isOpaque = false
        self.radius = radius
        self.lineWidth = lineWidth
    }

    override open func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        drawBackground(ctx)
        drawGradient(ctx, in: rect)
        drawHandle(ctx)
    }

    fileprivate func drawGradient(_ ctx: CGContext, in rect: CGRect) {
        UIGraphicsBeginImageContext(self.bounds.size)
        let imageCtx = UIGraphicsGetCurrentContext()

        let currentDegrees = degreesFromValue(_value) - startAngle

        imageCtx?.addArc(center: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0),
                         radius: radius,
                         startAngle: CGFloat(degreesToRadians(startAngle)),
                         endAngle: CGFloat(degreesToRadians(-currentDegrees)),
                         clockwise: true)
        UIColor.red.set()
        imageCtx?.setShadow(offset: .zero, blur: shadowBlur, color: UIColor.black.cgColor)
        imageCtx?.setLineWidth(lineWidth)
        imageCtx?.setLineCap(.round)

        imageCtx?.drawPath(using: .stroke)
        guard let mask: CGImage = UIGraphicsGetCurrentContext()?.makeImage() else { return }
        UIGraphicsEndImageContext()
        ctx.saveGState()

        ctx.clip(to: self.bounds, mask: mask)

        //Draw the gradient
        let startColorComps = startColor.cgColor.components!
        let endColorComps = endColor.cgColor.components!

        let components = [
            startColorComps[0], startColorComps[1], startColorComps[2], 1.0,
            endColorComps[0], endColorComps[1], endColorComps[2], 1.0
        ]

        let baseSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: baseSpace,
                                  colorComponents: components,
                                  locations: nil,
                                  count: 2)!
        let startPoint = CGPoint(x: rect.midX, y: rect.minY)
        let endPoint = CGPoint(x: rect.midX, y: rect.maxY)

        ctx.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: CGGradientDrawingOptions(rawValue: 0))

        ctx.restoreGState()
    }

    fileprivate func drawBackground(_ ctx: CGContext) {
        let start = CGFloat(radiansFromValue(minimumValue))
        let end = CGFloat(radiansFromValue(maximumValue))
        ctx.addArc(center: CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0),
                   radius: radius,
                   startAngle: start,
                   endAngle: end,
                   clockwise: true)
        ctx.setStrokeColor(trackColor.cgColor)
        ctx.setLineWidth(lineWidth + 2.0)
        ctx.setLineCap(.butt)
        ctx.drawPath(using: .stroke)
    }

    fileprivate func drawHandle(_ ctx: CGContext) {
        ctx.saveGState()
        ctx.setShadow(offset: .zero, blur: 3, color: UIColor.black.cgColor)

        let center = pointFromValue(_value)

        handleColor.set()
        ctx.fillEllipse(in: CGRect(x: center.x,// + CGFloat(handleRadius),
                                   y: center.y,// + CGFloat(handleRadius),
                                   width: handleRadius * 2,
                                   height: handleRadius * 2))
        ctx.restoreGState()
    }

    fileprivate func moveHandle(_ lastPoint: CGPoint) {
        let center = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        _value = valueFromPoint(center: center, point: lastPoint)
        setNeedsDisplay()
    }

    // MARK: - Utils
    func valueFromPoint(center: CGPoint, point: CGPoint) -> Double {
        var v: CGPoint = CGPoint(x: point.x - center.x, y: point.y - center.y)
        let vmag: CGFloat = square(square(v.x) + square(v.y))
        v.x /= vmag;
        v.y /= vmag;
        let radians = Double(atan2(v.y, v.x)) + degreesToRadians(startAngle)
        let value = valueFromRadians(radians)
        return value
    }

    func pointFromValue(_ value: Double) -> CGPoint {
        let centerPoint = CGPoint(x: self.frame.size.width / 2.0 - handleRadius, y: self.frame.size.height / 2.0 - handleRadius)
        var point: CGPoint = .zero

        let x = round(Double(radius) * cos(radiansFromValue(value) - degreesToRadians(startAngle))) + Double(centerPoint.x)
        let y = round(Double(radius) * sin(radiansFromValue(value) - degreesToRadians(startAngle)) ) + Double(centerPoint.y)
        point.x = CGFloat(x)
        point.y = CGFloat(y)

        return point
    }

    func square(_ value: CGFloat) -> CGFloat {
        return value * value
    }

    func valueFromRadians(_ radians: Double) -> Double {
        let range = maximumValue - minimumValue
        let result = radians * (range / 2) / Double.pi + minimumValue
        return (result >= minimumValue ? result : range + result)
    }

    func degreesToRadians(_ degrees: Double) -> Double {
        return degrees * Double.pi / 180.0
    }

    func radiansToDegrees(_ radians: Double) -> Double {
        return radians * 180.0 / Double.pi
    }

    func degreesFromValue(_ value: Double) -> Double {
        return radiansToDegrees(radiansFromValue(value))
    }

    func radiansFromValue(_ value: Double) -> Double {
        let range = maximumValue - minimumValue
        return (value - minimumValue) * Double.pi / (range / 2)
    }

    // MARK: - UIControl
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.beginTracking(touch, with: event)
        return true
    }

    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let handleLocation = pointFromValue(_value)
        let distance = handleLocation.distance(to: point)
        if distance <= 20.0 {
            return self
        }
        return nil
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        super.continueTracking(touch, with: event)

        let lastPoint = touch.location(in: self)
        self.moveHandle(lastPoint)
        self.sendActions(for: .valueChanged)
        return true
    }

    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        // Send the drag end event
    }
}

@IBDesignable extension CircularControl {
    @IBInspectable var _lineWidth: CGFloat {
        get { return self.lineWidth }
        set { self.lineWidth = newValue }
    }
    @IBInspectable var _radius: CGFloat {
        get { return self.radius }
        set { self.radius = newValue}
    }
    @IBInspectable var _trackBg: UIColor {
        get { return self.trackColor }
        set { self.trackColor = newValue }
    }
    @IBInspectable var _trackStart: UIColor {
        get { return self.startColor }
        set { self.startColor = newValue }
    }
    @IBInspectable var _trackEnd: UIColor {
        get { return self.endColor }
        set { self.endColor = newValue }
    }
    @IBInspectable var _trackShadowBlur: CGFloat {
        get { return self.shadowBlur }
        set { self.shadowBlur = newValue }
    }
    @IBInspectable var _minValue: Double {
        get { return self.minimumValue }
        set { self.minimumValue = newValue }
    }
    @IBInspectable var _maxValue: Double {
        get { return self.maximumValue }
        set { self.maximumValue = newValue }
    }
    @IBInspectable var __value: Double {
        get { return self.value }
        set { self.value = newValue }
    }
    @IBInspectable var _startAngle: Double {
        get { return self.startAngle }
        set { self.startAngle = newValue }
    }
    @IBInspectable var _handleRadius: CGFloat {
        get { return self.handleRadius }
        set { self.handleRadius = newValue }
    }
    @IBInspectable var _handleColor: UIColor {
        get { return self.handleColor }
        set { self.handleColor = newValue }
    }

}

private extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let xDist = self.x - point.x
        let yDist = self.y - point.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
}
