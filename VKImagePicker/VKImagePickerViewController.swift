
import UIKit

public enum ImagePickerType {
    case onlyCamera
    case onlyPhotoLib
    case all
}

public protocol VKImagePickerControllerDelegate:class {
    func didSelectDone(_ imagePicker:UIViewController,images:[UIImage])
    func didCancel(_ imagePicker:UIViewController)
}

public class VKImagePickerViewController: UIViewController {
    public var isCanEdit = true
    
    public var imageLimit:UInt = UInt(MAXINTERP)
    
    public var configuration:VKConfiguration = VKConfiguration.init()
    
    public weak var delegate:VKImagePickerControllerDelegate?
    
    var cameraView : VKCameraView?
    
    var assetView:VKImageAssetView?
    
    public var selectImages = [UIImage].init()
    
    public var type:ImagePickerType = .onlyPhotoLib
    
    public var shouldSavePhoto = false
    
    //vc circle
    open override func viewDidLoad() {
        super.viewDidLoad()
        if checkInfoDictionary(){
            prepareSubViews()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func prepareSubViews(){
        switch type {
        case .onlyCamera:
            cameraView = VKCameraView.init(frame: view.bounds, configure: configuration.cameraConfigure,maxImageCount:imageLimit)
            cameraView?.delegate = self
            view.addSubview(cameraView!)
        case .onlyPhotoLib:
            assetView = VKImageAssetView.init(configure: configuration.assetConfigure, maxCount: imageLimit)
            assetView?.delegate = self
            view.addSubview(assetView!)
        default:
            break
        }
    }
    
    @objc func applicationDidEnterBackground(){
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
        }
    }
    

    
    // MARK: - Initialization
    public required init(configuration: VKConfiguration? = nil,imageLimit:UInt = 5) {
        if let conf = configuration{
            self.configuration = conf
        }
        self.imageLimit = imageLimit
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }

    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.configuration = VKConfiguration.init()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.configuration = VKConfiguration.init()
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .fullScreen
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIInterfaceOrientation.portrait
    }

}

// MARK:other
extension VKImagePickerViewController{
    func checkInfoDictionary()->Bool{
        let photoLibrary = Bundle.main.infoDictionary?["NSPhotoLibraryUsageDescription"] as? String ?? ""
        let camera = Bundle.main.infoDictionary?["NSCameraUsageDescription"] as? String ?? ""
        if photoLibrary.count  == 0 || camera.count  == 0{
            assertionFailure("check out your infoDictionary,no permession!!!(NSPhotoLibraryUsageDescription and NSCameraUsageDescription)")
            return false
        }else{
            return true
        }
    }
    
    func selectDone(with images:[UIImage]){
        if shouldSavePhoto{
            DispatchQueue.init(label: "ImagePicker.save",qos: .utility).async {
                for image in images{
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.saveError(_:didFinishSavingWithError:contextInfo:)), nil)
                }
            }
        }
        delegate?.didSelectDone(self, images: images)
    }
    
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
    }
    
    func presentEditViewController(with images:[UIImage]){
        let vc = VKImageEditPreviewViewController.init(images: images,configure:configuration.editConfigure)
        let navagation = UINavigationController.init(rootViewController: vc)
        vc.delegate = self
        navagation.modalPresentationStyle = .fullScreen
        self.present(navagation, animated: true, completion: nil)
    }
    
}
// MARK:AssetViewDelegate
extension VKImagePickerViewController:AssetViewDelegate{
    func didCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func didSelectDone(_ images: [UIImage]) {
        selectImages = Array.init(images)
        if isCanEdit{
            presentEditViewController(with: selectImages)
        }else{
            selectDone(with: selectImages)
        }
    }
    

}

// MARK:VKCameraViewDelegate
extension VKImagePickerViewController:VKCameraViewDelegate{
    func camerViewBackButtonClick() {
        delegate?.didCancel(self)
    }
    
    func capuredImageDone(images: [UIImage]) {
        if !Set(images).isSubset(of: Set(selectImages)){
            selectImages.append(contentsOf: images)
        }
        if isCanEdit{
            presentEditViewController(with: selectImages)
        }else{
            selectDone(with: selectImages)
        }
    }
    
}

extension VKImagePickerViewController:VKImagePickerControllerDelegate{
    public func didCancel(_ imagePicker: UIViewController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    public func didSelectDone(_ imagePicker: UIViewController, images: [UIImage]) {
        selectDone(with: images)
    }
}
