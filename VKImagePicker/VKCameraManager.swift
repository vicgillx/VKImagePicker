//
//  VKCameraManager.swift
//  VKImagePicker
//
//  Created by karl  on 9/9/2020.
//  Copyright © 2020 karl. All rights reserved.
//

import Foundation
import AVFoundation
import PhotosUI

protocol CameraManagerDelegate:class {
    func cameraNotAvailable()
    func cameraDidStart()
    func camera(didChangedInput input:AVCaptureDeviceInput)
}

class VKCameraManager:NSObject{
    weak var delegate:CameraManagerDelegate?
    
    let session = AVCaptureSession.init()
    let queue = DispatchQueue.init(label: "com.karl.VKImagePicker.camera.sessionQueue")
    
    var backCamera:AVCaptureDeviceInput?
    var frontCamera:AVCaptureDeviceInput?
    var imageOutput:AVCapturePhotoOutput?
    var isFrontCamera = false
    
    var currentInput: AVCaptureDeviceInput? {
      return session.inputs.first as? AVCaptureDeviceInput
    }
    
    init(isFrontCamera:Bool) {
        self.isFrontCamera = isFrontCamera
        
    }
    
    deinit {
        end()
    }
    
    func presentSessionSize()->CGSize{
        switch session.sessionPreset {
        case .hd1920x1080:
            return CGSize.init(width: 1920, height: 1080)
        case .hd1280x720:
            return CGSize.init(width: 1280, height: 720)
        default:
            return CGSize.init(width: 640, height: 480)
        }
    }
    
    func setupDevices(){
        if session.canSetSessionPreset(.hd1920x1080){
            session.sessionPreset = .hd1920x1080
        }else if session.canSetSessionPreset(.hd1280x720){
            session.sessionPreset = .hd1280x720
        }else{
            session.sessionPreset = .vga640x480
        }
        session.sessionPreset = .vga640x480
        setupCaptureDevice()
        imageOutput = AVCapturePhotoOutput.init()
        
    }

    func setupCaptureDevice(){
        if let frontDevice = getCamera(.front){
            frontCamera = try? AVCaptureDeviceInput.init(device: frontDevice)
            
        }
        
        if let backDevice = getCamera(.back){
            backCamera = try?  AVCaptureDeviceInput.init(device: backDevice)
        }

    }


    func getCamera(_ positon:AVCaptureDevice.Position)->AVCaptureDevice?{
        if #available(iOS 10.2, *) {
            if let device = AVCaptureDevice.default(.builtInDualCamera,
                                                    for: AVMediaType.video,
                                                    position: positon) {
                return device
            } else if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                           for: AVMediaType.video,
                                                           position: positon) {
                return device
            }
            else {
                return nil
            }
        } else {
            if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
            for: AVMediaType.video,
            position: positon){
                return device
            }else{
                return nil
            }
        }
    }
    

    
    func configure(_ block:() -> Void){
        session.beginConfiguration()
        block()
        session.commitConfiguration()
    }
}


// MARK:Control
extension VKCameraManager{
    func start(){
        self.configure {
            setupDevices()
            guard let fCamera = frontCamera,let bCamera = backCamera,let output = imageOutput else { return }
            let input = isFrontCamera ? fCamera : bCamera
            if session.canAddInput(input){
                session.addInput(input)
                DispatchQueue.main.async {
                    self.delegate?.camera(didChangedInput: input)
                }
            }
            
            if session.canAddOutput(output){
                session.addOutput(output)
            }
        }
        

        queue.async {
            self.session.startRunning()
            DispatchQueue.main.async {
                self.delegate?.cameraDidStart()
            }
        }
        
    }
    
    func end(){
        self.session.stopRunning()
    }
    
    func switchCamera(){
        isFrontCamera = !isFrontCamera
        var hadBrokeCamera = false
        queue.async {
            self.configure {
                if let current = self.currentInput{
                    self.session.removeInput(current)
                }else{ hadBrokeCamera = true }
                if let input = self.isFrontCamera ? self.frontCamera : self.backCamera{
                    self.session.addInput(input)
                }
                if hadBrokeCamera,let output = self.imageOutput{
                    if self.session.canAddOutput(output){
                        if !self.session.outputs.contains(output){
                             self.session.addOutput(output)
                        }
                    }
                }
            }
            
        }
        if hadBrokeCamera{
            DispatchQueue.main.async {
                if !self.session.isRunning{
                    self.session.startRunning()
                }
                self.delegate?.cameraDidStart()
            }
        }
    }
}

// MARK:permission
extension VKCameraManager{
    func permissionCheck(){
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch status {
        case .authorized:
            start()
        case .notDetermined:
            requestPermission()
        default:
            DispatchQueue.main.async {
                self.delegate?.cameraNotAvailable()
            }
        }
    }
    
    func requestPermission(){
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { access in
            DispatchQueue.main.async {
                if access{
                    self.start()
                }else{
                    self.delegate?.cameraNotAvailable()
                }
            }
        }
    }
    
}
