# VKImagePicker

第三方的相机框架已经无法满足某些人的要求了,自撸了一个,纯swift,支持相机(单拍、连拍),相册选取,选取完后自定义编辑(画线条、剪裁)

- [Demo](#Demo)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)

## Demo
请使用`VKImagePicker.xcwrokspace`来运行
![](https://wx2.sinaimg.cn/mw690/006V86amgy1gj5d5ziw3dj31sa0u0qvb.jpg)

## Requirements
- iOS 10.0+
- Xcode 11+
- swift 5.0+

## Installation
### Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks. To integrate VKPageView into your Xcode project using Carthage

- specify it in your Cartfile
- `github  "vicgillx/VKImagePicker"`
- then use `carthage update`
### Swift Package Manager
To install IQKeyboardManager package via Xcode

- Go to File -> Swift Packages -> Add Package Dependency...
- Then search for `https://github.com/vicgillx/VKImagePicker`
- And choose the version you want

## Usage
参考项目里的demo
### setup
```
//自定义设置外观
let config = VKConfiguration()
let vc : VKImagePickerViewController = VKImagePickerViewController.init(configuration: config)
vc.delegate = self
vc.imageLimit = 3
vc.type = .onlyPhotoLib
self.present(vc, animated: true, completion: nil)
```

### delegate
```
func didCancel(_ imagePicker: UIViewController) {
	imagePicker.presentingViewController?.dismiss(animated: true, completion: nil)
}
    
func didSelectDone(_ imagePicker: UIViewController, images: [UIImage]) {
	self.images = images
	imagePicker.presentingViewController?.dismiss(animated: true, completion: nil)
	self.collectionView.reloadData()
}
```