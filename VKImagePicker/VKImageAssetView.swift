//
//  VKImageAssetView.swift
//  VKImagePicker
//
//  Created by siyu jiang on 2020/9/26.
//  Copyright © 2020 karl. All rights reserved.
//

import UIKit
import Photos

protocol AssetViewDelegate:class {
    func didCancel()
    func didSelectDone(_ images:[UIImage])
}


class VKImageAssetView: UIView {
    
    struct Demension {
        static let doneButtonHeight:CGFloat = 36
        static let doneButtonMinWidth:CGFloat = 6
        static let doneButtontrailingOffset:CGFloat = -12
        static let doneButtontopOffset:CGFloat = 12
        static let topViewHeight:CGFloat = statusHeight + 64
        static let bottomViewHeight:CGFloat = 70
    }
    
    lazy var topView : AssetTopView = {
        let view = AssetTopView.init(frame: CGRect.zero)
        view.backgroundColor = configure.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backButton.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        return view
    }()
    
    lazy var doneButton:UIButton = {
        let doneButton = UIButton.init(type: .custom)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        doneButton.setTitleColor(UIColor.white, for: .normal)
        doneButton.setTitleColor(UIColor.init(white: 1, alpha: 0.5), for: .disabled)
        doneButton.layer.cornerRadius = 5
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        doneButton.isEnabled = false
        return doneButton
    }()
    
    lazy var previewButton:UIButton = {
        let previewButton = UIButton.init(type: .custom)
        previewButton.setTitle(configure.previewButtonTitle, for: .normal)
        previewButton.setTitleColor(UIColor.white, for: .normal)
        previewButton.setTitleColor(UIColor.init(white: 1, alpha: 0.5), for: .disabled)
        previewButton.translatesAutoresizingMaskIntoConstraints = false
        previewButton.addTarget(self, action: #selector(previewButtonClick), for: .touchUpInside)
        previewButton.isEnabled = false
        return previewButton
        
    }()
    
    lazy var bottomView:UIView = {
        let view = UIView.init(frame: CGRect.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = configure.backgroundColor
        view.addSubview(previewButton)
        view.addSubview(doneButton)
        return view
    }()
    
    lazy var assetCollectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout.init()

        layout.itemSize = CGSize.init(width: AssetCollectionViewCell.itemWidth, height: AssetCollectionViewCell.itemHeight)
        layout.minimumInteritemSpacing = AssetCollectionViewCell.spacing
        layout.minimumLineSpacing = AssetCollectionViewCell.spacing
        layout.sectionInset = UIEdgeInsets.zero
        let collection = UICollectionView.init(frame: CGRect.zero, collectionViewLayout: layout)
        collection.backgroundColor = configure.backgroundColor
        collection.register(AssetCollectionViewCell.self, forCellWithReuseIdentifier: "AssetCollectionViewCell")
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = UIColor.clear
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    var assets =  [PHAsset].init()
    
    var resolveAssets = [UIImage].init()
    
    var selectIndexs = [IndexPath].init(){
        didSet{
            if selectIndexs.count > 0 {
                setDoneButton("\(configure.doneButtonTitle)(\(selectIndexs.count))")
            }else{
                setDoneButton(configure.doneButtonTitle)
            }
            previewButton.isEnabled = selectIndexs.count > 0
            doneButton.isEnabled = selectIndexs.count > 0
        }
    }
    
    var configure = VKAssetConfigure.init()
    
    var maxCount:UInt = 5
    
    weak var delegate:AssetViewDelegate?
    
    init(configure:VKAssetConfigure = VKAssetConfigure.init(),maxCount:UInt){
        super.init(frame: UIScreen.main.bounds)
        self.maxCount = maxCount
        self.configure = configure
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup(){
        prepareSubViewLayout()
        backgroundColor = configure.backgroundColor
        self.topView.backgroundColor = configure.topAndBottomViewBackgroundColor
        self.bottomView.backgroundColor = configure.topAndBottomViewBackgroundColor
        self.doneButton.backgroundColor = UIColor.init(red: 67.0/255.0, green: 205.0/255.0, blue: 128.0/255.0, alpha: 1)
        setDoneButton(configure.doneButtonTitle)
        requestPermission()
    }
    
    func setDoneButton(_ title:String){
        doneButton.setTitle("  \(title)  ", for: .normal)
        doneButton.sizeToFit()
    }
    
    func prepareSubViewLayout(){
        addSubview(topView)
        topView.backButton.setTitle(configure.backButtonTitle, for: .normal)
        addSubview(bottomView)
        //setup bottomView layout
        NSLayoutConstraint.activate([
            doneButton.heightAnchor.constraint(equalToConstant: Demension.doneButtonHeight),
            doneButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: Demension.doneButtontrailingOffset),
            doneButton.topAnchor.constraint(equalTo: bottomView.topAnchor, constant: Demension.doneButtontopOffset),
            doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: Demension.doneButtonMinWidth),
            previewButton.centerYAnchor.constraint(equalTo: doneButton.centerYAnchor),
            previewButton.heightAnchor.constraint(equalToConstant: Demension.doneButtonHeight),
            previewButton.widthAnchor.constraint(equalToConstant: 80),
            previewButton.leadingAnchor.constraint(equalTo: bottomView.leadingAnchor, constant: 12)
        ])
        
        //setup self layout
        addSubview(assetCollectionView)
        NSLayoutConstraint.activate([
            topView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            topView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            topView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topView.heightAnchor.constraint(equalToConstant: Demension.topViewHeight),
            assetCollectionView.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 0),
            assetCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            assetCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            assetCollectionView.bottomAnchor.constraint(equalTo: bottomView.topAnchor),
            bottomView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            bottomView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            bottomView.heightAnchor.constraint(equalToConstant: Demension.bottomViewHeight)
        ])
    }
    
    
    func requestPermission(){
        let currentStatus = PHPhotoLibrary.authorizationStatus()
        guard currentStatus != .authorized else {
            reloadAsset()
            return
        }

        if currentStatus == .notDetermined {  }

        PHPhotoLibrary.requestAuthorization { (authorizationStatus) -> Void in
          DispatchQueue.main.async {
            if authorizationStatus == .denied {
              self.presentAskPermissionAlert()
            } else if authorizationStatus == .authorized {
              self.reloadAsset()
            }
          }
        }

    }
    
    func reloadAsset(){
        AssetManager.fetch { (PhAsset) in
            self.assets = Array.init(PhAsset)
            self.resolveAssets = Array.init(AssetManager.resolveAssets(PhAsset))
            self.assetCollectionView.reloadData()
        }
    }
    
    func presentAskPermissionAlert(){
        let permissionView = VKRequestPermissionView.init(message: AssetManager.getLocalString("requestCameraPermissionMessage")) { _ in
            self.delegate?.didCancel()
        }
        addSubview(permissionView)
    }
    
    func currentSelectImages()->[UIImage]{
        var images = [PHAsset].init()
        for (idx,asset) in assets.enumerated(){
            if selectIndexs.contains(IndexPath.init(row: idx, section: 0)){
                images.append(asset)
            }
        }
        let list =  AssetManager.resolveOriginAssets(images)
        return list
    }
    
    // MARK:action method
    @objc func previewButtonClick(){
        delegate?.didSelectDone(currentSelectImages())
    }
    
    @objc func doneButtonClick(){
        delegate?.didSelectDone(currentSelectImages())
    }
    
    @objc func backButtonClick(){
        self.delegate?.didCancel()
    }
}


extension VKImageAssetView:UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return resolveAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AssetCollectionViewCell", for: indexPath) as! AssetCollectionViewCell
        cell.assetImageView.image = resolveAssets[indexPath.row]
        if let index = selectIndexs.firstIndex(of: indexPath){
            cell.indexLabel.isHidden = false
            cell.statusImageView.isHidden = true
            cell.indexLabel.text = "\(index+1)"
        }else{
            cell.indexLabel.isHidden = true
            cell.statusImageView.isHidden = false
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let originSelectList :[IndexPath] = Array.init(selectIndexs)
        if let index =  selectIndexs.firstIndex(of: indexPath){
            selectIndexs.remove(at: index)
            collectionView.reloadItems(at: originSelectList)
        }else{
            guard selectIndexs.count < maxCount else {
                let permissionView = VKRequestPermissionView.init(message: configure.reachMaxAlert) {  permission in
                    permission.removeFromSuperview()
                }
                addSubview(permissionView)
                return
            }
            selectIndexs.append(indexPath)
            collectionView.reloadItems(at: selectIndexs)
        }
        
    }
}



