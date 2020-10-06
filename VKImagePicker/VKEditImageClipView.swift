//
//  VKEditImageClipView.swift
//  VKImagePicker
//
//  Created by siyu jiang on 2020/10/3.
//

import UIKit

class VKEditImageClipView: UIView {
    
    private struct Demesion {
        static let buttonWidth:CGFloat = 20
        static let bottomOffset:CGFloat = 40
        static let buttonsVerticalIntervel:CGFloat = 30
        static let leading:CGFloat = 18
    }
    lazy var scrollView:UIScrollView = {
        let scrollView = UIScrollView.init()
        scrollView.backgroundColor = .black
        scrollView.isScrollEnabled = true
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.delegate = self
        return scrollView
    }()
    
    let containerView = UIView.init()
    
    lazy var contentImageView:UIImageView = {
        let imgView = UIImageView.init()
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .clear
        return imgView
    }()
    
    let closeButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.tag = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(AssetManager.getImage("close"), for: .normal)
        button.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    let sureButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.tag = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(AssetManager.getImage("right"), for: .normal)
        button.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    let rotationButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.tag = 2
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(AssetManager.getImage("rotateimage"), for: .normal)
        button.addTarget(self, action: #selector(buttonClick(sender:)), for: .touchUpInside)
        return button
    }()
    
    var editImage:UIImage?
    
    var editCompletion:((UIImage?)->Void)?
    
    init(image:UIImage,completion: ((UIImage?)->Void)?) {
        super.init(frame: UIScreen.main.bounds)
        editImage = image
        editCompletion = completion
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        UIView.animate(withDuration: 1.0) {
            self.contentImageView.transform = CGAffineTransform.init(scaleX: 0.85, y: 0.85)
        }
    }
    
    func setup(){
        addSubview(scrollView)
        scrollView.addSubview(containerView)
        containerView.addSubview(contentImageView)
        
        scrollView.frame = self.frame
        containerView.frame = scrollView.frame
        contentImageView.frame = containerView.bounds
        
        contentImageView.image = editImage
        contentImageView.frame = contentImageView.contentClippingRect
        
        addSubview(closeButton)
        addSubview(sureButton)
        addSubview(rotationButton)
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: Demesion.buttonWidth),
            closeButton.heightAnchor.constraint(equalToConstant: Demesion.buttonWidth),
            closeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Demesion.bottomOffset),
            closeButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Demesion.leading),
            sureButton.widthAnchor.constraint(equalToConstant: Demesion.buttonWidth),
            sureButton.heightAnchor.constraint(equalToConstant: Demesion.buttonWidth),
            sureButton.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor),
            sureButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Demesion.leading),
            rotationButton.widthAnchor.constraint(equalToConstant: Demesion.buttonWidth),
            rotationButton.heightAnchor.constraint(equalToConstant: Demesion.buttonWidth),
            rotationButton.centerXAnchor.constraint(equalTo: closeButton.centerXAnchor),
            rotationButton.bottomAnchor.constraint(equalTo: closeButton.topAnchor, constant: -Demesion.buttonsVerticalIntervel)
        ])
    }
    
    //tag 0 = close ,1 = sure , 2 = rotation
    @objc func buttonClick(sender:UIButton){
        if sender.tag == 0{
            self.removeFromSuperview()
        }else if sender.tag == 1{
            editCompletion?(contentImageView.screenShot)
            self.removeFromSuperview()
        }else if sender.tag == 2{
            print("image origional size = \(editImage!.size)")
            let image = editImage?.rotationImage(with: 90)
            
            contentImageView.image = image
            contentImageView.frame = contentImageView.contentClippingRect
            //contentImageView.transform = CGAffineTransform.init(rotationAngle: .pi/2)
        }
    }
    
}

extension VKEditImageClipView:UIScrollViewDelegate{
    
}
