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
    enum CaptureMode {
        case photo
        case video
        case livePhoto
    }
    
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition?
    
    var frontCamera: AVCaptureDevice?
//    var frontCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    
    var rearCamera: AVCaptureDevice?
//    var rearCameraInput: AVCaptureDeviceInput?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    
    var currentCaptureInput: AVCaptureInput?
    var currentCaptureOutput: AVCaptureOutput?
    
    var capturingVideo: Bool = false
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
                let rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                
                if captureSession.canAddInput(rearCameraInput) {
                    captureSession.addInput(rearCameraInput)
                    currentCaptureInput = rearCameraInput
                }
                
                self.currentCameraPosition = .rear
            }
                
            else if let frontCamera = self.frontCamera {
                let frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(frontCameraInput) {
                    captureSession.addInput(frontCameraInput)
                    currentCaptureInput = frontCameraInput
                }
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
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.insertSublayer(self.previewLayer!, at: 0)

        setPreviewOrientation()
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
        if let previewLayer = previewLayer {
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.frame = UIScreen.main.bounds

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
            
            previewLayer.connection?.videoOrientation = captureOrientation
        }
    }
    
//    func switchToFrontCamera() throws {
//        guard
//            let captureSession = self.captureSession,
//            captureSession.isRunning
//        else {
//            throw CameraControllerError.captureSessionIsMissing
//        }
//
//        captureSession.beginConfiguration()
//        try switchToFrontCamera(inSession: captureSession)
//        captureSession.commitConfiguration()
//        currentCameraPosition = .front
//    }
    
//    func switchToRearCamera() throws {
//        guard
//            let captureSession = self.captureSession,
//            captureSession.isRunning
//            else {
//                throw CameraControllerError.captureSessionIsMissing
//        }
//
//        configure(cameraPosition: currentCameraPosition,
//                  captureMode: <#T##CameraController.CaptureMode#>)
//
//        captureSession.beginConfiguration()
//        try switchToRearCamera(inSession: captureSession)
//        captureSession.commitConfiguration()
//        currentCameraPosition = .rear
//    }
    
    func configure(cameraPosition: CameraPosition,
                   captureMode: CaptureMode) throws {
        guard
            let captureSession = self.captureSession,
            captureSession.isRunning
        else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()

        //
        // Device
        //
        let deviceToAdd: AVCaptureDevice
        
        switch cameraPosition {
        case .front:
            deviceToAdd = self.frontCamera!
        case .rear:
            deviceToAdd = self.rearCamera!
        }
        
        let cameraInput = try AVCaptureDeviceInput(device: deviceToAdd)
        if let inputToRemove = currentCaptureInput {
            captureSession.removeInput(inputToRemove)
            currentCaptureInput = nil
        }
        
        if captureSession.canAddInput(cameraInput) {
            captureSession.addInput(cameraInput)
            currentCaptureInput = cameraInput
            
            currentCameraPosition = cameraPosition
        } else {
            throw CameraControllerError.invalidOperation
        }
        
        //
        // Output data
        //
        if let outputToRemove = currentCaptureOutput {
            captureSession.removeOutput(outputToRemove)
            currentCaptureOutput = nil
        }
        
        // TODO: Split out based on capture mode...
        if captureMode == .video {
            let movieDataOutput = AVCaptureMovieFileOutput()
            
            movieDataOutput.maxRecordedDuration = CMTime(seconds: 10, preferredTimescale: 1)
            movieDataOutput.minFreeDiskSpaceLimit = 1_000_000
//            let videoDataOutput = AVCaptureVideoDataOutput()
//
//            videoDataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
//
//            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            
            if captureSession.canAddOutput(movieDataOutput) {
                captureSession.addOutput(movieDataOutput)
                currentCaptureOutput = movieDataOutput
            }
            
            if captureSession.canSetSessionPreset(AVCaptureSession.Preset.high) {
                captureSession.sessionPreset = AVCaptureSession.Preset.high
            } else if captureSession.canSetSessionPreset(AVCaptureSession.Preset.medium) {
                captureSession.sessionPreset = AVCaptureSession.Preset.medium
            } else if captureSession.canSetSessionPreset(AVCaptureSession.Preset.low) {
                captureSession.sessionPreset = AVCaptureSession.Preset.low
            }
        }
        
        currentCameraPosition = cameraPosition
        
        captureSession.commitConfiguration()
    }
    
//    private func switchToFrontCamera(inSession captureSession: AVCaptureSession) throws {
//        guard let inputs = captureSession.inputs as [AVCaptureInput]?,
//            let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
//            let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
//
//        self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
//
//        captureSession.removeInput(rearCameraInput)
//
//        if captureSession.canAddInput(self.frontCameraInput!) {
//            captureSession.addInput(self.frontCameraInput!)
//
//            self.currentCameraPosition = .front
//        }
//
//        else {
//            throw CameraControllerError.invalidOperation
//        }
//    }
    
//    private func switchToRearCamera(inSession captureSession: AVCaptureSession) throws {
//        guard let inputs = captureSession.inputs as [AVCaptureInput]?,
//            let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
//            let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
//
//        self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
//
//        captureSession.removeInput(frontCameraInput)
//
//        if captureSession.canAddInput(self.rearCameraInput!) {
//            captureSession.addInput(self.rearCameraInput!)
//
//            self.currentCameraPosition = .rear
//        }
//
//        else { throw CameraControllerError.invalidOperation }
//    }
    
//    func switchCameras() throws {
//        guard
//            let currentCameraPosition = currentCameraPosition,
//            let captureSession = self.captureSession, captureSession.isRunning
//            else { throw CameraControllerError.captureSessionIsMissing }
//
//        captureSession.beginConfiguration()
//
//        switch currentCameraPosition {
//        case .front:
//            try switchToRearCamera(inSession: captureSession)
//
//        case .rear:
//            try switchToFrontCamera(inSession: captureSession)
//        }
//
//        captureSession.commitConfiguration()
//    }
    
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
    
    func captureVideo(completion: @escaping (Any?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else {
            completion(nil,  CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let movieDataOutput = currentCaptureOutput as! AVCaptureMovieFileOutput
        if !movieDataOutput.isRecording {
            print("Capture Video")
            
            let localFileURL = MediaManager.GetNextFileURL(filenamePrefix: "CameraMovie-",
                                                           numberOfDigits: 6,
                                                           filenamePostfix: ".mov")
            
            movieDataOutput.startRecording(to: localFileURL!,
                                           recordingDelegate: self)
        } else {
            movieDataOutput.stopRecording()
        }
    }
}

extension CameraController: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            print("Error occurred capturing movie \(error)")
        } else {
            print("Movie should have captured fine to \(outputFileURL)")
        }
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
