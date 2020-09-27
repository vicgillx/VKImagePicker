//
//  DemoCollectionViewCell.swift
//  Demo
//
//  Created by siyu jiang on 2020/9/27.
//

import UIKit

class DemoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var contentImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.masksToBounds = true
    }
}
