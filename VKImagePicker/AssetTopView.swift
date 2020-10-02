//
//  AssetTopView.swift
//  VKImagePicker
//
//  Created by siyu jiang on 2020/9/26.
//  Copyright © 2020 karl. All rights reserved.
//

import UIKit

class AssetTopView: UIView {
    
    let backButton : UIButton = {
        let button  = UIButton.init(type: .custom)
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        return button
    }()
    
    let titleLabel:UILabel = {
        let label = UILabel.init(frame: CGRect.zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        label.font = UIFont.init(name: "Helvetica-Bold", size: 18)
        label.text = AssetManager.getLocalString("PhotoStream")
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)
        addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 120),
            titleLabel.heightAnchor.constraint(equalToConstant: 32),
            
            backButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor, constant: 0),
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
            backButton.widthAnchor.constraint(equalToConstant: 60),
            backButton.heightAnchor.constraint(equalToConstant: 25)
        ])
    }

}
