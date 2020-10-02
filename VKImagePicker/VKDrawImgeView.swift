//
//  VKDrawImgeView.swift
//  VKImagePicker
//
//  Created by karl  on 18/9/2020.
//  Copyright © 2020 karl. All rights reserved.
//

import UIKit
import CoreImage
protocol DrawImageViewDelegate:class {
    func didStartDraw()
    func shouldStopDraw()
    func drawColorLineDidChange(_ currentLines:[CAShapeLayer]?)
}

enum ImageViewDrawType {
    case none
    case line
    case mosia
}

class VKDrawImgeView: UIImageView {
    private lazy var previousTouchPoint = CGPoint.zero
    
    var contentClippingRect: CGRect {
            guard let image = image else { return bounds }
            guard contentMode == .scaleAspectFit else { return bounds }
            guard image.size.width > 0 && image.size.height > 0 else { return bounds }

            let scale: CGFloat
            if image.size.width > image.size.height {
                scale = bounds.width / image.size.width
            } else {
                scale = bounds.height / image.size.height
            }

            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            let x = (bounds.width - size.width) / 2.0
            let y = (bounds.height - size.height) / 2.0

            return CGRect(x: x, y: y, width: size.width, height: size.height)
    }

    var drawColorLayers = [[CAShapeLayer]].init(){
        didSet{
            drawDelegate?.drawColorLineDidChange(drawColorLayers.last)
        }
    }
    
    var tempDrawLayer = [CAShapeLayer].init()
    
    var drawColor = UIColor.white
    var type:ImageViewDrawType = .none
    
    weak var drawDelegate:DrawImageViewDelegate?
    
    var startTime:DispatchTime?
    
    var mosicMaskView:UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()
    
    var mosicMaskLayers = [[CAShapeLayer]].init(){
        didSet{
            drawDelegate?.drawColorLineDidChange(mosicMaskLayers.last)
        }
    }
    
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
        addSubview(mosicMaskView)
        mosicMaskView.isHidden = true
    }
    
    private func setupLayer(path:UIBezierPath,lineWidht:CGFloat = 3)->CAShapeLayer{
        let layer = CAShapeLayer.init()
        layer.path = path.cgPath
        layer.lineWidth = lineWidht
        layer.strokeColor = self.drawColor.cgColor
        layer.fillColor = self.drawColor.cgColor
        return layer
    }
    
    func prepareMosica(_  completion: (Bool)->Void){
        type = .mosia
        guard let img = self.image,!self.subviews.contains(mosicMaskView),mosicMaskView.frame == self.bounds else {
            completion(false)
            return
        }
        let filter = CIFilter(name: "CIPixellate")!
        let inputImage = CIImage(image: img)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        filter.setValue(50, forKey: kCIInputScaleKey)
        let fullPixellatedImage = filter.outputImage

        guard let cgImage = CIContext.init(options: nil).createCGImage(fullPixellatedImage!, from: fullPixellatedImage!.extent)
        else {
            completion(false)
            return
        }
        self.mosicMaskView.image = UIImage.init(cgImage: cgImage)
        self.mosicMaskView.frame = self.bounds
        self.mosicMaskView.isHidden = false
        self.mosicMaskView.layer.mask = CALayer.init()
        completion(true)
    }
    
    func revokeLastDraw(){
        switch type {
        case .line:
            removeContentLastLayer(layers: &drawColorLayers)
        case .mosia:
            removeContentLastLayer(layers: &mosicMaskLayers)
        default:
            return
        }
    }
    
    private func removeContentLastLayer( layers:inout [[CAShapeLayer]]){
        if let lastDraws = layers.last{
            for layer in lastDraws{
                layer.removeFromSuperlayer()
            }
            layers.removeLast()
        }
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
            tempDrawLayer = [CAShapeLayer].init()
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
        if tempDrawLayer.count > 0 {
            switch type {
            case .line:
                drawColorLayers.append(tempDrawLayer)
            case .mosia:
                mosicMaskLayers.append(tempDrawLayer)
            default:
                break
            }
            
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .milliseconds(max)) {
            if !self.isTouchStart{
                self.drawDelegate?.shouldStopDraw()
            }
            
        }
    }
    


    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        if let location = touches.first?.location(in: self) {
            let path = UIBezierPath.init()
            path.move(to: location)
            path.addLine(to: previousTouchPoint)
            previousTouchPoint = location
            switch type {
            case .line:
                let layer = setupLayer(path: path)
                self.tempDrawLayer.append(layer)
                self.layer.addSublayer(layer)
            case .mosia:
                let layer = setupLayer(path: path,lineWidht: 6)
                self.tempDrawLayer.append(layer)
                self.mosicMaskView.layer.mask?.addSublayer(layer)
            default:
                break
            }

        }
    }
}
