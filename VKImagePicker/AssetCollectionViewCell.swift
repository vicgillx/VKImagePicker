//
//  AssetCollectionViewCell.swift
//  VKImagePicker
//
//  Created by siyu jiang on 2020/9/26.
//  Copyright © 2020 karl. All rights reserved.
//

import UIKit
private let selectControlWidth:CGFloat = 20
class AssetCollectionViewCell: UICollectionViewCell {
    
    static let itemOneLineCount:CGFloat = 4
    static let spacing:CGFloat = 2
    static let itemWidth = (UIScreen.main.bounds.width - spacing*(itemOneLineCount - 1))/itemOneLineCount
    static let itemHeight = itemWidth*1.1
    
    
    let assetImageView:UIImageView = UIImageView.init()
    let statusImageView:UIImageView = UIImageView.init(image: AssetManager.getImage("unselected"))
    let indexLabel:UILabel = {
        let label = UILabel.init()
        label.text = ""
        
        label.textAlignment = .center
        label.backgroundColor = UIColor.init(red: 67.0/255.0, green: 205.0/255.0, blue: 128.0/255.0, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.layer.cornerRadius = selectControlWidth/2
        label.layer.masksToBounds = true
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.masksToBounds = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func  setup() {
        assetImageView.translatesAutoresizingMaskIntoConstraints = false
        assetImageView.contentMode = .scaleAspectFill
        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        indexLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(assetImageView)
        contentView.addSubview(statusImageView)
        contentView.addSubview(indexLabel)
        NSLayoutConstraint.activate([
            assetImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            assetImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            assetImageView.widthAnchor.constraint(equalToConstant: AssetCollectionViewCell.itemWidth),
            assetImageView.heightAnchor.constraint(equalToConstant: AssetCollectionViewCell.itemHeight),
            
            statusImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            statusImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            statusImageView.heightAnchor.constraint(equalToConstant: selectControlWidth),
            statusImageView.widthAnchor.constraint(equalToConstant: selectControlWidth),
            
            indexLabel.centerXAnchor.constraint(equalTo: statusImageView.centerXAnchor),
            indexLabel.centerYAnchor.constraint(equalTo: statusImageView.centerYAnchor),
            indexLabel.widthAnchor.constraint(equalToConstant: selectControlWidth),
            indexLabel.heightAnchor.constraint(equalToConstant: selectControlWidth)
        ])
    }
}
