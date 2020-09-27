//
//  VKEditPreviewCollectionViewCell.swift
//  VKImagePicker
//
//  Created by karl  on 11/9/2020.
//  Copyright © 2020 karl. All rights reserved.
//

import UIKit


class VKEditPreviewCollectionViewCell: UICollectionViewCell {
    
    let thumbnailImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(thumbnailImageView)
        layer.masksToBounds = true
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: self.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
