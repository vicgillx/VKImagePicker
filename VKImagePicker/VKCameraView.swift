

import UIKit
import AVFoundation
import PhotosUI
protocol VKCameraViewDelegate:class {
    func camerViewBackButtonClick()
    func capuredImageDone(images:[UIImage])
}
class VKCameraView: UIView {
    
    var previewLayer : AVCaptureVideoPreviewLayer?

    var configure = VKImageCameraConfiguration()
    
    weak var delegate:VKCameraViewDelegate?
    
    var maxImageCount :UInt = 5
    
    var isFrontCamera = false
    
    var cameraManager : VKCameraManager =  VKCameraManager.init(isFrontCamera: false)
    
    var capuredImages = [UIImage].init()
    
    deinit {
        
    }

    
    var takePhotoButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("", for: .normal)
        button.addTarget(self, action: #selector(takePhotoButtonClick), for: .touchUpInside)
        return button
    }()
    
    var capturedImageView : UIImageView = {
        let imageView = UIImageView.init()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    lazy var backButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("", for: .normal)
        button.setImage(nil, for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(backButtonClick), for: .touchUpInside)
        return button
    }()
    
    lazy var reverseCameraButton : UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("", for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(reverseCameraClick), for: .touchUpInside)
        return button
    }()
    
    var containerView :UIView = {
        let view = UIView.init()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    lazy var capturedCountLabel : UILabel = {
        let label = UILabel.init()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = ""
        return label
    }()
    
    lazy var doneButton:UIButton = {
        let button = UIButton.init(type: .custom)
        button.setTitle("", for: .normal)
        button.setImage(nil, for: .normal)
        button.addTarget(self, action: #selector(doneButtonClick), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    init(frame:CGRect,configure:VKImageCameraConfiguration,maxImageCount:UInt = 1) {
        super.init(frame:frame)
        self.configure = configure
        self.maxImageCount = maxImageCount
        setup()
    } 
    
    func setup(){
        backgroundColor = configure.backgroundColor
        cameraManager.delegate = self
        cameraManager.permissionCheck()
        setupSubViews()
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        } else {
           
        }
    }
    
    
    func setupPreview(){
        previewLayer = AVCaptureVideoPreviewLayer(session: cameraManager.session)

        previewLayer?.backgroundColor = configure.backgroundColor.cgColor
        previewLayer?.autoreverses = true
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        containerView.layer.addSublayer(previewLayer!)
        previewLayer?.frame = CGRect.init(origin: CGPoint.zero, size: containerView.bounds.size)
        
    }
    
    func setupSubViews(){
        backButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(backButton)
        backButton.titleLabel?.font = configure.doneButtonFont
        backButton.setTitleColor(configure.backButtonTitleColor, for: .normal)
        
        reverseCameraButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(reverseCameraButton)
        reverseCameraButton.setImage(configure.reverseCameraImage, for: .normal)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        takePhotoButton.translatesAutoresizingMaskIntoConstraints = false
        takePhotoButton.setImage(configure.photographImage, for: .normal)
        addSubview(takePhotoButton)
        
        capturedImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(capturedImageView)
        
        capturedCountLabel.font = configure.capuredCountLabelFont
        capturedCountLabel.textColor = configure.capuredCountLabelTitleColor
        capturedCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(capturedCountLabel)
        
        doneButton.titleLabel?.font = configure.doneButtonFont
        doneButton.setTitleColor(configure.doneButtonTitleColor, for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(doneButton)
        
        switch configure.doneButtonDemensions {
        case .image(let image):
            doneButton.setImage(image, for: .normal)
        case .title(let title):
            doneButton.setTitle(title, for: .normal)
        }
        switch configure.backButtonDemensions {
        case .image(let image):
            backButton.setImage(image, for: .normal)
        case .title(let title):
            backButton.setTitle(title, for: .normal)
        }
        
        
        let topSide = statusBarHeight + configure.backButtonTopOffset
        
        NSLayoutConstraint.activate([
            backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: topSide),
            backButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: configure.backButtonLeadingOffset),
            backButton.widthAnchor.constraint(equalToConstant: configure.backButtonSize.width),
            backButton.heightAnchor.constraint(equalToConstant: configure.backButtonSize.height),
            
            reverseCameraButton.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            reverseCameraButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: configure.reverseCameraTrailingOffset),
            reverseCameraButton.widthAnchor.constraint(equalToConstant: configure.reverseCameraSize.width),
            reverseCameraButton.heightAnchor.constraint(equalToConstant: configure.reverseCameraSize.height),
            
            containerView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: configure.photoPreviewEdage.top),
            containerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: configure.photoPreviewEdage.left),
            containerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: configure.photoPreviewEdage.right),
            containerView.bottomAnchor.constraint(equalTo: takePhotoButton.topAnchor, constant: -configure.photoPreviewEdage.bottom),
            
            takePhotoButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            takePhotoButton.widthAnchor.constraint(equalToConstant: configure.photographImageSize.width),
            takePhotoButton.heightAnchor.constraint(equalToConstant: configure.photographImageSize.height),
            takePhotoButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -configure.photographImageBottomOffset),
            
            capturedImageView.centerYAnchor.constraint(equalTo: takePhotoButton.centerYAnchor),
            capturedImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: configure.capuredImageLeadingOffset),
            capturedImageView.widthAnchor.constraint(equalToConstant: configure.capuredImageSize.width),
            capturedImageView.heightAnchor.constraint(equalToConstant: configure.capuredImageSize.height),
            
            capturedCountLabel.centerXAnchor.constraint(equalTo: capturedImageView.centerXAnchor),
            capturedCountLabel.topAnchor.constraint(equalTo: capturedImageView.bottomAnchor, constant: 8),
            capturedCountLabel.widthAnchor.constraint(equalToConstant: 120),
            
            doneButton.centerYAnchor.constraint(equalTo: takePhotoButton.centerYAnchor),
            doneButton.widthAnchor.constraint(equalToConstant: configure.doneButtonSize.width),
            doneButton.heightAnchor.constraint(equalToConstant: configure.doneButtonSize.height),
            doneButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: configure.doneButtonTrailingOffset)
            
        ])
        let _ = containerViewConstraints()
        bringSubviewToFront(backButton)
    }
    
    
    func containerViewConstraints()->[NSLayoutConstraint]?{
        let size = cameraManager.presentSessionSize()
        print("capuredImage Size = \(size),w/h = \(size.height/size.width)")
        print("previewSize = \(currentPreviewSize()),w/h = \(currentPreviewSize().width/currentPreviewSize().height)")
        return nil
    }
    
    
    func currentPreviewSize()->CGSize{
        let width = self.bounds.width - configure.photoPreviewEdage.left - configure.photoPreviewEdage.right
        let height = self.bounds.height - configure.backButtonTopOffset - configure.backButtonSize.height - configure.photoPreviewEdage.top - configure.photoPreviewEdage.bottom - configure.photographImageSize.height - configure.photographImageBottomOffset
        return CGSize.init(width: width, height: height)
    }
    
    
    func handleCapuredImage(_ image:UIImage){
        if capuredImages.count < maxImageCount{
            capuredImages.append(image)
        }else if capuredImages.count == maxImageCount,maxImageCount != 1{
            let permissionView = VKRequestPermissionView.init(message: configure.capuredReachMaxAlert) {  permission in
                permission.removeFromSuperview()
            }
            addSubview(permissionView)
            return
        }

        if maxImageCount == 1{
            delegate?.capuredImageDone(images: capuredImages)
            return
        }
        
        capturedImageView.image = capuredImages.last

        capturedCountLabel.text = "\(capuredImages.count)"
        doneButton.isHidden = false
    }
    
    func capuredImageSelectDone(){
        if capuredImages.count == 0{
            delegate?.camerViewBackButtonClick()
        }else{
            delegate?.capuredImageDone(images: capuredImages)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:Action methods
extension VKCameraView{
    @objc func backButtonClick(){
        delegate?.camerViewBackButtonClick()
    }
    
    @objc func takePhotoButtonClick(){
        if cameraManager.session.isRunning,cameraManager.session.inputs.count != 0{
            var photoSettings = AVCapturePhotoSettings()

            if #available(iOS 11.0, *),(self.cameraManager.imageOutput?.availablePhotoCodecTypes.contains(.jpeg)) != nil{
                    photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
            }
            
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [
                    kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!
                ]
            }
            photoSettings.isAutoStillImageStabilizationEnabled = true
            cameraManager.imageOutput?.capturePhoto(with: photoSettings, delegate: self)
            
        }
    }
    
    @objc func reverseCameraClick(){
        cameraManager.switchCamera()
    }
    
    @objc func doneButtonClick(){
        capuredImageSelectDone()
    }


}

// MARK:AVCapturePhotoCaptureDelegate
extension VKCameraView:AVCapturePhotoCaptureDelegate{

    @available(iOS 11.0, *)
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error == nil,let date = photo.fileDataRepresentation(),let capturedImage = UIImage.init(data: date){
            

            handleCapuredImage(capturedImage)
            
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        guard let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer),let image = UIImage(data:dataImage,scale:1.0)  else {
           return
        }
        handleCapuredImage(image)
    }
    
}

// MARK:Action CameraManagerDelegate
extension VKCameraView:CameraManagerDelegate{
    func cameraNotAvailable() {
        let permissionView = VKRequestPermissionView.init(message: AssetManager.getLocalString("requestCameraPermissionMessage")) { _ in
            self.delegate?.camerViewBackButtonClick()
        }
        addSubview(permissionView)
    }
    
    func cameraDidStart() {
        setupPreview()
    }
    
    func camera(didChangedInput input: AVCaptureDeviceInput) {
        
    }
}

// MARK:Control
extension VKCameraView{

}

