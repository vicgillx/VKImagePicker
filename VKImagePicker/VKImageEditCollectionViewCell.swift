

import UIKit

let EditCollectionViewCellMaxWidth:CGFloat = 25
let EditCollectionViewCellMinWidth:CGFloat = 20
class VKImageEditCollectionViewCell: UICollectionViewCell {
    let contentImageView = UIImageView.init()
    let circleView:UIView = {
        let view = UIView.init()
        
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(contentImageView)
        contentView.addSubview(circleView)
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            contentImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            contentImageView.widthAnchor.constraint(equalToConstant: EditCollectionViewCellMaxWidth),
            contentImageView.heightAnchor.constraint(equalToConstant: EditCollectionViewCellMaxWidth),
            circleView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: EditCollectionViewCellMinWidth),
            circleView.heightAnchor.constraint(equalToConstant: EditCollectionViewCellMinWidth)
        ])
        circleView.layer.cornerRadius = 10
        circleView.layer.masksToBounds = true
        circleView.layer.borderColor = UIColor.white.cgColor
        circleView.layer.borderWidth = 1
        circleView.isHidden = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

