
import Foundation
import UIKit
import Photos

open class AssetManager {
    
    public static func getLocalString(_ key:String)->String{
        var bundle = Bundle(for: AssetManager.self)
          
        if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/VKImagePickerBundle.bundle") {
          bundle = resourceBundle
        }
        let result =  NSLocalizedString(key, bundle:bundle, comment: "")
        return result

    }
    
    public static func getImage(_ name: String) -> UIImage {
      let traitCollection = UITraitCollection(displayScale: 3)
      var bundle = Bundle(for: AssetManager.self)
        
      if let resource = bundle.resourcePath, let resourceBundle = Bundle(path: resource + "/VKImagePickerBundle.bundle") {
        bundle = resourceBundle
      }
      let image = UIImage.init(named: "\(name).tiff", in: bundle, compatibleWith: traitCollection)
        
      return image ?? UIImage.init()
    }
    
    public static func fetch(_ completion: @escaping (_ assets: [PHAsset]) -> Void) {
      guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
      DispatchQueue.global(qos: .background).async {
        let fetchResult = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())

        if fetchResult.count > 0 {
            
          var assets = [PHAsset]()
            fetchResult.enumerateObjects({ object, _, _ in
                assets.append(object)
            })

          DispatchQueue.main.async {
            completion(assets)
          }
        }
      }
    }
    
    public static func resolveOriginAssets(_ assets:[PHAsset])->[UIImage]{
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.version = .original
        var images = [UIImage].init()
        for asset in assets{
            manager.requestImageData(for: asset, options: options) { data, _, orientation, _ in
                if let imageData = data,let image = UIImage.init(data: imageData){
                    images.append(image)
                }
            }
        }
        return images
    }
    
    public static func resolveOriginAsset(_ asset:PHAsset,completion:@escaping (_ image:UIImage?)->Void ){
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.version = .original
        manager.requestImageData(for: asset, options: options) { data, _, orientation, _ in
            DispatchQueue.main.async {
                if let imageData = data,let image = UIImage.init(data: imageData){
                    completion(image)
                }else{
                    completion(nil)
                }
            }
        }
    }
    
    public static func resolveAsset(_ asset: PHAsset, size: CGSize = CGSize(width: 720, height: 1280), shouldPreferLowRes: Bool = false, completion: @escaping (_ image: UIImage?) -> Void) {
      let imageManager = PHImageManager.default()
      let requestOptions = PHImageRequestOptions()
      requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
      requestOptions.isNetworkAccessAllowed = true

      imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, info in
        if let info = info, info["PHImageFileUTIKey"] == nil {
          DispatchQueue.main.async(execute: {
            completion(image)
          })
        }
      }
    }
    
    public static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
      let imageManager = PHImageManager.default()
      let requestOptions = PHImageRequestOptions()
      requestOptions.isSynchronous = true

      var images = [UIImage]()
      for asset in assets {
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: requestOptions) { image, _ in
          if let image = image {
            images.append(image)
          }
        }
      }
      return images
    }
}
