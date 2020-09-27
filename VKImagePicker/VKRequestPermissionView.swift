//
//  VKRequestPermissionView.swift
//  VKImagePicker
//
//  Created by karl  on 10/9/2020.
//  Copyright © 2020 karl. All rights reserved.
//

import UIKit

private let  defaultFont = UIFont.systemFont(ofSize: 16)
typealias backClickBlock = (UIView)->Void
class VKRequestPermissionView: UIView {
    
    private struct Demesions {
        static let leadOffset :CGFloat = 40
        static let trailOffset :CGFloat = -leadOffset
        static let buttonHeight : CGFloat = 40
        static let messageEdage = UIEdgeInsets.init(top: 24, left: 18, bottom: -24, right: -18)
    }
    
    var suerButton :UIButton = {
        let button = UIButton.init()
    
        button.setTitle(AssetManager.getLocalString("ok"), for: .normal)
        button.setTitleColor(UIColor.init(red: 82.0/255.0, green: 147.0/255.0, blue: 1, alpha: 1), for: .normal)
        button.addTarget(self, action: #selector(sureButtonClick), for: .touchUpInside)
        button.titleLabel?.font = defaultFont
        button.backgroundColor = UIColor.clear
        return button
    }()
    
    var messageLabel : UILabel = {
        let label = UILabel.init()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = defaultFont
        label.backgroundColor = UIColor.clear
        label.textColor = UIColor.white
        return label
    }()
    
    var contentView : UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.gray
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()
    
    var backClick:backClickBlock?
    
    init(message:String,back:  @escaping backClickBlock) {
        super.init(frame: UIScreen.main.bounds)
        self.backClick = back
        self.backgroundColor = UIColor.init(white: 0, alpha: 0.5)
        messageLabel.text = message
        setup()
    }
    
    func setup(){
        contentView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        suerButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        contentView.addSubview(suerButton)
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Demesions.messageEdage.top),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Demesions.messageEdage.left),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Demesions.messageEdage.right),
            messageLabel.bottomAnchor.constraint(equalTo: suerButton.topAnchor, constant: Demesions.messageEdage.bottom),
            
            suerButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            suerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            suerButton.heightAnchor.constraint(equalToConstant: Demesions.buttonHeight),
            suerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
        ])
        
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Demesions.leadOffset),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: Demesions.trailOffset),
            contentView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ])
        suerButton.addSeparatorLine(.top, color: UIColor.white,size:CGSize.init(width: self.bounds.width-Demesions.leadOffset-Demesions.trailOffset, height: Demesions.buttonHeight))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func sureButtonClick(){
        if self.backClick != nil {
            self.backClick!(self)
        }
    }
    
}
