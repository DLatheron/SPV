//
//  RealCameraController.swift
//  SPV
//
//  Created by dlatheron on 25/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//
//  Based on: https://github.com/appcoda/FullScreenCamera/blob/master/CameraController.swift
//  Created by Pranjal Satija on 29/5/2017.
//  Copyright © 2017 AppCoda. All rights reserved.
//

import AVFoundation
import UIKit

class CameraController: NSObject {
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    var frontCamera: AVCaptureDevice?
    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var rearCamera: AVCaptureDevice?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
}

extension CameraController {
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession() {
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                           mediaType: AVMediaType.video,
                                                           position: .unspecified)
            // TODO: KVO observing of devices that are available during session - as the user can remove grant/permissions during a run.
            let cameras = session.devices.flatMap { $0 }
            
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession
                else {
                    throw CameraControllerError.captureSessionIsMissing
                }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                
                self.currentCameraPosition = .front
            }
                
            else { throw CameraControllerError.noCamerasAvailable }
        }
        
        func configurePhotoOutput() throws {
            guard let captureSession = self.captureSession
                else {
                    throw CameraControllerError.captureSessionIsMissing
                }
            
            let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
            setting.isHighResolutionPhotoEnabled = true
            setting.isAutoDualCameraFusionEnabled = true
            setting.isAutoStillImageStabilizationEnabled = true;
            let settings = [ setting ]
            
            let capture = AVCapturePhotoOutput()
            capture.setPreparedPhotoSettingsArray(settings, completionHandler: nil)
            capture.isLivePhotoCaptureEnabled = capture.isLivePhotoCaptureSupported && true
            capture.isHighResolutionCaptureEnabled = true
            capture.isDualCameraDualPhotoDeliveryEnabled = capture.isDualCameraDualPhotoDeliverySupported && true

            self.photoOutput = capture
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard
            let captureSession = self.captureSession,
            captureSession.isRunning
            else {
                throw CameraControllerError.captureSessionIsMissing
            }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        setPreviewOrientation()
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    var captureDevice: AVCaptureDevice? {
        get {
            guard
                let captureSession = self.captureSession,
                captureSession.isRunning
            else {
                return nil
            }

            switch currentCameraPosition {
            case .front?: return frontCamera
            case .rear?: return rearCamera
            default: return nil
            }
        }
    }
    
    var hasFlash: Bool {
        get {
            if let captureDevice = captureDevice {
                return captureDevice.hasFlash && captureDevice.isFlashAvailable
            } else {
                return false
            }
        }
    }
    
    func setPreviewOrientation() {
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        let captureOrientation: AVCaptureVideoOrientation
        
        switch UIScreen.main.orientation {
        case .portrait:
            captureOrientation = .portrait
        case .landscapeLeft:
            captureOrientation = .landscapeLeft
        case .landscapeRight:
            captureOrientation = .landscapeRight
        case .portraitUpsideDown:
            captureOrientation = .portraitUpsideDown
        default:
            captureOrientation = .portrait
        }
        
        self.previewLayer?.connection?.videoOrientation = captureOrientation
    }
    
    func switchToFrontCamera() throws {
        guard
            let captureSession = self.captureSession,
            captureSession.isRunning
        else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()
        try switchToFrontCamera(inSession: captureSession)
        captureSession.commitConfiguration()
        currentCameraPosition = .front
    }
    
    func switchToRearCamera() throws {
        guard
            let captureSession = self.captureSession,
            captureSession.isRunning
            else {
                throw CameraControllerError.captureSessionIsMissing
            }
        
        captureSession.beginConfiguration()
        try switchToRearCamera(inSession: captureSession)
        captureSession.commitConfiguration()
        currentCameraPosition = .rear
    }
    
    private func switchToFrontCamera(inSession captureSession: AVCaptureSession) throws {
        guard let inputs = captureSession.inputs as [AVCaptureInput]?, let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
            let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
        
        self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
        
        captureSession.removeInput(rearCameraInput)
        
        if captureSession.canAddInput(self.frontCameraInput!) {
            captureSession.addInput(self.frontCameraInput!)
            
            self.currentCameraPosition = .front
        }
            
        else {
            throw CameraControllerError.invalidOperation
        }
    }
    
    private func switchToRearCamera(inSession captureSession: AVCaptureSession) throws {
        guard let inputs = captureSession.inputs as [AVCaptureInput]?, let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
            let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
        
        self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
        
        captureSession.removeInput(frontCameraInput)
        
        if captureSession.canAddInput(self.rearCameraInput!) {
            captureSession.addInput(self.rearCameraInput!)
            
            self.currentCameraPosition = .rear
        }
            
        else { throw CameraControllerError.invalidOperation }
    }
    
    func switchCameras() throws {
        guard
            let currentCameraPosition = currentCameraPosition,
            let captureSession = self.captureSession, captureSession.isRunning
            else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera(inSession: captureSession)
            
        case .rear:
            try switchToFrontCamera(inSession: captureSession)
        }
        
        captureSession.commitConfiguration()
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {
                completion(nil,  CameraControllerError.captureSessionIsMissing)
                return
            }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
}

extension CameraController: AVCapturePhotoCaptureDelegate {
//    public func photoOutput(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
//                        resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
//        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
//
//        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
//            let image = UIImage(data: data) {
//
//            self.photoCaptureCompletionBlock?(image, nil)
//        }
//
//        else {
//            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
//        }
//    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock?(nil, error)
        } else if let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data) {
            self.photoCaptureCompletionBlock?(image, nil)
        } else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown)
        }

    }
}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}
