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

/*
import AVFoundation
import UIKit

class CameraController: NSObject {
    enum CaptureMode {
        case photo
        case video
        case livePhoto
    }
    
    let jpegPhotoImageQuality: CGFloat = 0.8
    
    var captureSession: AVCaptureSession?
    
    var currentCameraPosition: CameraPosition = .rear
    var currentCaptureMode: CaptureMode = .livePhoto
    
    var frontCamera: AVCaptureDevice?
    
    var rearCamera: AVCaptureDevice?
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var videoCaptureCompletionBlock: ((URL?, Error?) -> Void)?
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    var livePhotoCaptureCompletionBlock: ((LivePhoto?, Error?) -> Void)?
    var livePhoto: LivePhoto?
    
    var currentCaptureInput: AVCaptureInput?
    var currentCaptureOutput: AVCaptureOutput?
    
    var capturingVideo: Bool = false
    
    var zoom: CGFloat {
        get {
            if let captureDevice = captureDevice {
                return captureDevice.videoZoomFactor
            } else {
                return 1.0
            }
        }
        set {
            if let captureDevice = captureDevice {
                do {
                    try captureDevice.lockForConfiguration()
                    captureDevice.videoZoomFactor = newValue
                    captureDevice.unlockForConfiguration()
                } catch {
                    print("Failed to set zoom")
                }
            }
        }
    }
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
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try self.configure(camera: self.currentCameraPosition,
                                   mode: self.currentCaptureMode)
                self.captureSession!.startRunning()
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
            case .front: return frontCamera
            case .rear: return rearCamera
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

//            let captureOrientation: AVCaptureVideoOrientation
            
            // TODO: Should we avoid doing any of this?
//            switch UIScreen.main.orientation {
//            case .portrait:
//                captureOrientation = .portrait
//            case .landscapeLeft:
//                captureOrientation = .landscapeLeft
//            case .landscapeRight:
//                captureOrientation = .landscapeRight
//            case .portraitUpsideDown:
//                captureOrientation = .portraitUpsideDown
//            default:
//                captureOrientation = .portrait
//            }
//
//            previewLayer.connection?.videoOrientation = captureOrientation
        }
    }
    
func configure(camera cameraPosition: CameraPosition,
                   mode captureMode: CaptureMode) throws {
        guard
            let captureSession = self.captureSession//,
            //captureSession.isRunning
        else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()

        //
        // Input device
        //
        let deviceToAdd: AVCaptureDevice?
        
        switch cameraPosition {
        case .front:
            deviceToAdd = self.frontCamera
        case .rear:
            deviceToAdd = self.rearCamera
        }
        
        if let deviceToAdd = deviceToAdd {
            //
            // Remove existing inputs and output
            //
            if let inputToRemove = currentCaptureInput {
                captureSession.removeInput(inputToRemove)
                currentCaptureInput = nil
            }
            if let outputToRemove = currentCaptureOutput {
                captureSession.removeOutput(outputToRemove)
                currentCaptureOutput = nil
            }

            //
            // Input device
            //
            let cameraInput = try AVCaptureDeviceInput(device: deviceToAdd)
            
            if captureSession.canAddInput(cameraInput) {
                captureSession.addInput(cameraInput)
                currentCaptureInput = cameraInput
            } else {
                throw CameraControllerError.invalidOperation
            }
            
            //
            // Output data
            //
            let dataOutput: AVCaptureOutput?
            
            switch captureMode {
            case .video:
                dataOutput = configure(session: captureSession,
                                       movieDataOutput: AVCaptureMovieFileOutput())
            case .photo:
                dataOutput = configure(session: captureSession,
                                       photoDataOutput: AVCapturePhotoOutput())
            case .livePhoto:
                dataOutput = configure(session: captureSession,
                                       livePhotoDataOutput: AVCapturePhotoOutput())
            }
            
            if captureSession.canAddOutput(dataOutput!) {
                captureSession.addOutput(dataOutput!)
                currentCaptureOutput = dataOutput
            } else {
                throw CameraControllerError.invalidOperation
            }
            
            captureSession.commitConfiguration()

            currentCameraPosition = cameraPosition
            currentCaptureMode = captureMode
        } else {
            throw CameraControllerError.noCamerasAvailable
        }
    }
}

/*
 * Video capture
 */
extension CameraController: AVCaptureFileOutputRecordingDelegate {
    fileprivate func configure(session captureSession: AVCaptureSession,
                               movieDataOutput: AVCaptureMovieFileOutput) -> AVCaptureOutput {
        movieDataOutput.maxRecordedDuration = CMTime(seconds: 10, preferredTimescale: 1)
        movieDataOutput.minFreeDiskSpaceLimit = 1_000_000
        //            let videoDataOutput = AVCaptureVideoDataOutput()
        //
        //            videoDataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String) : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange as UInt32)]
        //
        //            videoDataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canSetSessionPreset(AVCaptureSession.Preset.high) {
            captureSession.sessionPreset = AVCaptureSession.Preset.high
        } else if captureSession.canSetSessionPreset(AVCaptureSession.Preset.medium) {
            captureSession.sessionPreset = AVCaptureSession.Preset.medium
        } else if captureSession.canSetSessionPreset(AVCaptureSession.Preset.low) {
            captureSession.sessionPreset = AVCaptureSession.Preset.low
        }
        
        return movieDataOutput
    }
    
    func captureVideo(completion: @escaping (URL?, Error?) -> Void) {
        guard
            let captureSession = captureSession,
            captureSession.isRunning
        else {
            completion(nil,  CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let movieDataOutput = currentCaptureOutput as! AVCaptureMovieFileOutput
        print("Capture Video")
        
        let localFileURL = MediaManager.GetNextFileURL(filenamePrefix: "CameraMovie-",
                                                       numberOfDigits: 6,
                                                       filenamePostfix: ".mov")
        
        movieDataOutput.startRecording(to: localFileURL!,
                                       recordingDelegate: self)
        
        self.videoCaptureCompletionBlock = completion
        self.photoCaptureCompletionBlock = nil
        self.livePhotoCaptureCompletionBlock = nil
        self.livePhoto = nil
    }

    func stopCapturingVideo() {
        let movieDataOutput = currentCaptureOutput as! AVCaptureMovieFileOutput
        
        movieDataOutput.stopRecording()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput,
                    didFinishRecordingTo outputFileURL: URL,
                    from connections: [AVCaptureConnection],
                    error: Error?) {
        if let error = error {
            print("Error occurred capturing movie \(error)")
            self.videoCaptureCompletionBlock?(nil, error)
        } else {
            print("Movie should have captured fine to \(outputFileURL)")
            self.videoCaptureCompletionBlock?(outputFileURL, nil)
        }
    }
}

/*
 * Image capture
 */
extension CameraController: AVCapturePhotoCaptureDelegate {
    fileprivate func configure(session captureSession: AVCaptureSession,
                               photoDataOutput: AVCapturePhotoOutput) -> AVCaptureOutput {
        let setting = AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])
        setting.isHighResolutionPhotoEnabled = true
        setting.isAutoDualCameraFusionEnabled = true
        setting.isAutoStillImageStabilizationEnabled = true;
        let settings = [ setting ]
        
        photoDataOutput.setPreparedPhotoSettingsArray(settings,
                                                      completionHandler: nil)
        photoDataOutput.isLivePhotoCaptureEnabled = photoDataOutput.isLivePhotoCaptureSupported
        photoDataOutput.isHighResolutionCaptureEnabled = true
        photoDataOutput.isDualCameraDualPhotoDeliveryEnabled = photoDataOutput.isDualCameraDualPhotoDeliverySupported
        
        return photoDataOutput
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession,
            captureSession.isRunning
        else {
            completion(nil,  CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        let photoOutput = self.currentCaptureOutput as! AVCapturePhotoOutput
        
        photoOutput.capturePhoto(with: settings,
                                 delegate: self)
        
        self.videoCaptureCompletionBlock = nil
        self.photoCaptureCompletionBlock = completion
        self.livePhotoCaptureCompletionBlock = nil
        self.livePhoto = nil
    }
    
    // TODO: Make DRY
    func saveImageToLocalFileAsJPEG(image: UIImage,
                                    url: URL) throws {
        if let data = UIImageJPEGRepresentation(image, jpegPhotoImageQuality) {
            try? data.write(to: url,
                            options: [ .atomic, .completeFileProtection ])
        }
    }
    
    public func photoOutput(_ output: AVCapturePhotoOutput,
                            didFinishProcessingPhoto photo: AVCapturePhoto,
                            error: Error?) {
        if let error = error {
            self.photoCaptureCompletionBlock!(nil, error)
        } else if let data = photo.fileDataRepresentation(),
            let image = UIImage(data: data) {
            if let livePhoto = livePhoto {
//                try? self.saveImageToLocalFile(image: image,
//                                               url: livePhoto.heicURL)
                
                try? self.saveImageToLocalFileAsJPEG(image: image,
                                               url: livePhoto.imageURL)

            } else {
                self.photoCaptureCompletionBlock!(image, nil)
            }
        } else {
            self.photoCaptureCompletionBlock!(nil, CameraControllerError.unknown)
        }
    }
}

/*
 * Live Photo capture
 */
// TODO: Live Photo capture.
extension CameraController {
    fileprivate func configure(session captureSession: AVCaptureSession,
                               livePhotoDataOutput: AVCapturePhotoOutput) -> AVCaptureOutput {
        let setting = AVCapturePhotoSettings(format: [kCVPixelBufferPixelFormatTypeKey: ])
        setting.isHighResolutionPhotoEnabled = true
        //setting.isAutoDualCameraFusionEnabled = true
        //setting.isAutoStillImageStabilizationEnabled = true;
        let settings = [ setting ]
        
        livePhotoDataOutput.setPreparedPhotoSettingsArray(settings,
                                                          completionHandler: nil)
        livePhotoDataOutput.isHighResolutionCaptureEnabled = true
        livePhotoDataOutput.isLivePhotoCaptureEnabled = livePhotoDataOutput.isLivePhotoCaptureSupported
        livePhotoDataOutput.isDepthDataDeliveryEnabled = livePhotoDataOutput.isDepthDataDeliverySupported
        livePhotoDataOutput.isDualCameraDualPhotoDeliveryEnabled = livePhotoDataOutput.isDualCameraDualPhotoDeliverySupported
        
        return livePhotoDataOutput
    }
    
    func captureLivePhoto(completion: @escaping (LivePhoto?, Error?) -> Void) {
        guard let captureSession = captureSession,
            captureSession.isRunning
        else {
            completion(nil,  CameraControllerError.captureSessionIsMissing)
            return
        }
        
        let localDirectoryURL =
            MediaManager.GetNextDirectoryURL(directoryPrefix: "LivePhoto-",
                                             numberOfDigits: 6,
                                             directoryPostfix: ".livephoto")

        livePhoto = LivePhoto(directoryURL: localDirectoryURL!)

        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        //settings.livePhotoCapureEnabled = true
        settings.livePhotoMovieFileURL = livePhoto?.videoURL
        
        let photoOutput = self.currentCaptureOutput as! AVCapturePhotoOutput
        
        photoOutput.capturePhoto(with: settings,
                                 delegate: self)
        
        self.videoCaptureCompletionBlock = nil
        self.photoCaptureCompletionBlock = nil
        self.livePhotoCaptureCompletionBlock = completion
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL,
                     duration: CMTime,
                     photoDisplayTime: CMTime,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        if let error = error {
            self.livePhotoCaptureCompletionBlock!(nil, error)
        } else {
            print("Movie should have captured file to \(outputFileURL)")
            self.livePhotoCaptureCompletionBlock?(livePhoto!, nil)
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
 
 */
