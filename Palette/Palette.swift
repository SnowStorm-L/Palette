//
//  Palette.swift
//  Palette
//
//  Created by L on 2018/12/15.
//  Copyright © 2018 L. All rights reserved.
//

import UIKit

struct PixelRGB {
    var r: UInt8 = 0
    var g: UInt8 = 0
    var b: UInt8 = 0
}

protocol PaletteDelegate: class {
    func paletteDidChangeColor(color: UIColor)
}

class Palette: UIView {
    
    var radius: CGFloat = 0
    
    var radialImage = UIImage()
    
    var cursorRadius: CGFloat = 0
    
    var brightness: CGFloat = 0
    
    var currentColor: UIColor {
        let pixel = color(atPoint: viewToImageSpace(point: touchPoint))
        return UIColor(red: pixel.r.floatValue / 255.0,
                       green: pixel.g.floatValue / 255.0,
                       blue: pixel.b.floatValue / 255.0,
                       alpha: 1)
    }
    
    // Touch
    
    var touchPoint = CGPoint.zero
    
    var continuous = true
    
    weak var delegate: PaletteDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        brightness = 1.0
        cursorRadius = 8
        touchPoint = CGPoint(x: bounds.size.width / 2.0, y: bounds.size.height / 2.0)
        backgroundColor = .clear
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        radius = (min(frame.size.width, frame.size.height) / 2.0) - 1.0
        updateImage()
    }
    
    override func draw(_ rect: CGRect) {
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        let center = CGPoint(x: width / 2, y: height / 2)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("didn't find current context")
            return
        }
        
        context.saveGState()
        
        // 添加边框
        let ellipseRect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        
        context.addEllipse(in: ellipseRect)
        
        context.clip()
        
        if let radialCGImage = radialImage.cgImage {
            context.draw(radialCGImage, in: ellipseRect)
        } else {
            print("empty radialCGImage")
        }
        
        context.setLineWidth(1)
        context.setStrokeColor(UIColor.black.cgColor)
        
        // 添加选色框
        let touchRect = CGRect(x: touchPoint.x - cursorRadius,
                               y: touchPoint.y - cursorRadius, width: cursorRadius * 2, height: cursorRadius * 2)
        
        context.addEllipse(in: touchRect)
        context.addEllipse(in: ellipseRect)
        
        context.strokePath()
        
        context.restoreGState()
        
    }
    
}

private extension Palette {
    
    func updateImage() {
        
        let width = Int(radius * 2.0)
        let height = Int(radius * 2.0)
        
        let dataLength = MemoryLayout<PixelRGB>.size * width * height
        
        var data = [PixelRGB].init(repeating: PixelRGB(), count: dataLength)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelRGB = color(atPoint: CGPoint(x: x, y: y))
                data[x + y * width] = pixelRGB
            }
        }
        
        let bitInfo = CGBitmapInfo(rawValue: 0)
        
        guard let dataProvider = CGDataProvider(dataInfo: nil, data: data, size: dataLength, releaseData: {_, _, _ in}) else {
            return
        }
        
        let colorspace = CGColorSpaceCreateDeviceRGB()
        
        guard let cgImage = CGImage(width: width, height: height,
                                    bitsPerComponent: 8, bitsPerPixel: 24,
                                    bytesPerRow: width * 3, space: colorspace,
                                    bitmapInfo: bitInfo, provider: dataProvider,
                                    decode: nil, shouldInterpolate: true, intent: .defaultIntent)
            else {
                return
        }
        
        radialImage = UIImage(cgImage: cgImage)
        
        setNeedsDisplay()
    }
    
    func pointDistance(p1: CGPoint, p2: CGPoint) -> CGFloat {
        return sqrt((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y))
    }
    
    func HSVToRGB(h: CGFloat, s: CGFloat, v: CGFloat) -> PixelRGB {
        
        let newH = h * 6.0
        let i = floor(newH)
        let f = newH - i
        let p = v *  (1.0 - s)
        let q = v * (1.0 - s * f)
        let t = v * (1.0 - s * (1.0 - f))
        
        var r, g, b: CGFloat
        
        switch i {
        case 0:
            r = v
            g = t
            b = p
        case 1:
            r = q
            g = v
            b = p
        case 2:
            r = p
            g = v
            b = t
        case 3:
            r = p
            g = q
            b = v
        case 4:
            r = t
            g = p
            b = v
        default:
            r = v
            g = p
            b = q
        }
        
        var pixel = PixelRGB()
        pixel.r = UInt8(r * 255.0)
        pixel.g = UInt8(g * 255.0)
        pixel.b = UInt8(b * 255.0)
        
        return pixel
    }
    
    func color(atPoint point: CGPoint) -> PixelRGB {
        
        let center = CGPoint(x: radius, y: radius)
        
        let angle = atan2(point.x - center.x, point.y - center.y) + .pi
        
        let dist = pointDistance(p1: point, p2: CGPoint(x: center.x, y: center.y))
        
        var hue = angle / (.pi * 2)
        
        hue = min(hue, 1 - 0.0000001)
        hue = max(hue, 0)
        
        var sat = dist / radius
        
        sat = min(sat, 1)
        sat = max(sat, 0)
        
        return HSVToRGB(h: hue, s: sat, v: brightness)
    }
    
    func viewToImageSpace(point: CGPoint) -> CGPoint {
        
        var newPoint = point
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        newPoint.y = height - newPoint.y
        
        let min = CGPoint(x: width / 2 - radius, y: height / 2 - radius)
        
        newPoint.x = newPoint.x - min.x
        newPoint.y = newPoint.y - min.y
        
        return newPoint
    }
    
}

private extension UInt8 {
    var floatValue: CGFloat {
        return CGFloat(self)
    }
}

private extension Set where Element == UITouch {
    var touch: AnyObject {
        return ((self as NSSet).anyObject() as AnyObject)
    }
}

extension Palette {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      touchHandler(withTouches: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
       touchHandler(withTouches: touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.paletteDidChangeColor(color: currentColor)
    }
    
    func touchHandler(withTouches touches: Set<UITouch>) {
        let touch = touches.touch
        let point = touch.location(in: self)
        setTouchPoint(point: point)
        
        setNeedsDisplay()
        
        if continuous {
            delegate?.paletteDidChangeColor(color: currentColor)
        }
    }
    
    func setTouchPoint(point: CGPoint) {
        
        let width = bounds.size.width
        let height = bounds.size.height
        
        let center = CGPoint(x: width / 2, y: height / 2)
        
        // Check if the touch is outside the Palette
        if pointDistance(p1: center, p2: point) < radius {
            touchPoint = point
            return
        }
        
        var vec = CGPoint(x: point.x - center.x, y: point.y - center.y)
        
        let extents = sqrt((vec.x * vec.x) + (vec.y * vec.y))
        
        vec.x /= extents
        vec.y /= extents
        
        touchPoint = CGPoint(x: center.x + vec.x * radius, y: center.y + vec.y * radius)
    }
    
}
