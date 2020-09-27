//
//  VKDrawImgeView.swift
//  VKImagePicker
//
//  Created by karl  on 18/9/2020.
//  Copyright © 2020 karl. All rights reserved.
//

import UIKit

protocol DrawImageViewDelegate:class {
    func didStartDraw()
    func shouldStopDraw()
    func drawColorLineDidChange(_ currentLines:[CAShapeLayer])
}

enum ImageViewDrawType {
    case none
    case line
    case mosia
}

class VKDrawImgeView: UIImageView {
    private lazy var previousTouchPoint = CGPoint.zero

    var drawLayers = [CAShapeLayer].init(){
        didSet{
            drawDelegate?.drawColorLineDidChange(drawLayers)
        }
    }
    
    var drawColor = UIColor.white
    var lineWidth:CGFloat = 3
    var type:ImageViewDrawType = .none
    weak var drawDelegate:DrawImageViewDelegate?
    
    var startTime:DispatchTime?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setup(){
        isUserInteractionEnabled = true

    }
    private func setupLayer(path:UIBezierPath)->CAShapeLayer{
        let layer = CAShapeLayer.init()
        layer.path = path.cgPath
        layer.lineWidth = self.lineWidth
        layer.strokeColor = self.drawColor.cgColor
        return layer
    }
    
    func removeLastColorLine(){
        drawLayers.last?.removeFromSuperlayer()
    }
    
    func millisecondsToDouble(timeIntervel:DispatchTimeInterval) -> Double? {
            var result: Double?
            switch timeIntervel {
            case .seconds(let value):
                result = Double(value)*1000
            case .milliseconds(let value):
                result = Double(value)
            case .microseconds(let value):
                result = Double(value)*0.001
            case .nanoseconds(let value):
                result = Double(value)*0.000001
            case .never:
                result = nil
            @unknown default:
                result = nil
            }

            return result
        }
    
    var isTouchStart = false
    
    
// MARK:touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if type != .none,let location = touches.first?.location(in: self) {
            previousTouchPoint = location
            drawDelegate?.didStartDraw()
            startTime = DispatchTime.now()
            isTouchStart = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let max :Int = 1000
        isTouchStart = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(max)) {
            if !self.isTouchStart{
                self.drawDelegate?.shouldStopDraw()
            }
            
        }
    }
    


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let location = touches.first?.location(in: self) {
            switch type {
            case .line:
                let path = UIBezierPath.init()
                path.move(to: location)
                path.addLine(to: previousTouchPoint)
                previousTouchPoint = location
                let layer = setupLayer(path: path)
                self.drawLayers.append(layer)
                self.layer.addSublayer(layer)
            default:
                break
            }

        }
    }
}
