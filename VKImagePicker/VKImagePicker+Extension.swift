//
//  VKImagePicker+Extension.swift
//  VKImagePicker
//
//  Created by karl  on 9/9/2020.
//  Copyright © 2020 karl. All rights reserved.
//

import UIKit
let statusBarHeight : CGFloat = {
        let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        var statusBarHeight : CGFloat = 0
        if #available(iOS 13.0 , *){
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        }else{
            statusBarHeight = UIApplication.shared.statusBarFrame.size.height
        }
    
        return statusBarHeight
}()

extension CAShapeLayer{
    convenience init(from startPoint:CGPoint , to endPoint:CGPoint,strokeColor: UIColor,fillColor:UIColor,lineWidth:CGFloat = 1) {
        self.init()
        let bezier = UIBezierPath.init()
        
        let width = lineWidth/UIScreen.main.scale
        
        bezier.move(to: startPoint)
        
        bezier.addLine(to: endPoint)
        
        self.path = bezier.cgPath
        
        self.fillColor = fillColor.cgColor
        
        self.strokeColor = strokeColor.cgColor
        
        self.contentsScale = UIScreen.main.scale
        
        self.lineWidth = width
    }
    
}


extension UIView{
    enum ViewPositon {
        case top
        case left
        case right
        case bottom
    }
    func addSeparatorLine(_ postion:ViewPositon = .bottom,color:UIColor = UIColor.white,spacing:CGFloat = 0,size:CGSize?){
        var correctSize = bounds.size
        if size != nil {
            correctSize = size!
        }
        
        var start = CGPoint.zero
        var end = CGPoint.zero
        switch postion {
        case .top:
            start = CGPoint.init(x: 0, y: 0)
            end = CGPoint.init(x: correctSize.width, y: 0)
        case .left:
            start = CGPoint.init(x: 0, y: 0)
            end = CGPoint.init(x: 0, y: correctSize.height)
        case .right:
            start = CGPoint.init(x: correctSize.width, y: 0)
            end = CGPoint.init(x: correctSize.width, y:correctSize.height)
        default:
            start = CGPoint.init(x: 0, y: correctSize.height)
            end = CGPoint.init(x: correctSize.width, y: correctSize.height)
        }
        let line = CAShapeLayer.init(from: start, to: end, strokeColor: color, fillColor: color,lineWidth: 0.5)
        layer.addSublayer(line)
    }
    
    var screenShot: UIImage?  {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
            let screenshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return screenshot
        }
        return nil
    }
    
    func addFillConstraint(in super_view:UIView,insets:UIEdgeInsets){
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: super_view.topAnchor, constant: insets.top),
            self.leadingAnchor.constraint(equalTo: super_view.leadingAnchor, constant: insets.top),
            self.trailingAnchor.constraint(equalTo: super_view.trailingAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: super_view.bottomAnchor, constant: insets.top)
        ])
    }
}


extension UIImage{
    
    func scaleImageFit(with width:CGFloat) -> UIImage {
        let height = self.size.height/self.size.width*width
        let fitSize = CGSize.init(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(fitSize, false, UIScreen.main.scale)
        self.draw(in: CGRect.init(origin: CGPoint.zero, size: fitSize))
        let fitImage:UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage.init()
        UIGraphicsGetCurrentContext()
        return fitImage
    }
}

extension UIDevice{
    static var isSimulator:Bool{
        #if targetEnvironment(simulator)
                return true
        #else
                return false
        #endif
    }
}


