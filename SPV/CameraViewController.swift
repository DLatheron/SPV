/*
 See LICENSE.txt for this sample’s licensing information.
 
 Abstract:
 View controller for camera interface.
 */

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var uiFlashMode: FlashMode = .flashAuto
    var deviceFlashMode: AVCaptureDevice.FlashMode = FlashMode.flashAuto.deviceFlashMode
    
    var captureMode: CaptureMode = .photo
    var zoom: CGFloat = 1.0
    
    @IBOutlet private weak var cameraUnavailableLabel: UILabel!
    @IBOutlet var capturingLivePhotoLabel: UILabel!

    @IBOutlet private weak var flashModeButton: UIButton!
    @IBOutlet private weak var capturingLivePhotoIndicator: UILabel!
    @IBOutlet private weak var cameraButton: UIButton!
    
    @IBOutlet private weak var zoomButton: UIButton!
    
    @IBOutlet private weak var captureModeButton: UIButton!
    @IBOutlet private weak var captureButton: UIButton!
    @IBOutlet private weak var videoRecordingIndicator: UIView!
    @IBOutlet private weak var videoRecordingIndicatorXConstraint: NSLayoutConstraint!
    @IBOutlet private weak var videoRecordingIndicatorYConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var resumeButton: UIButton!
    @IBOutlet private weak var livePhotoModeButton: UIButton!
    
    @IBOutlet private weak var previewView: PreviewView!
    
    @IBAction private func toggleFlashMode(_ flashModeButton: UIButton) {
        sessionQueue.async {
            let flashMode = self.uiFlashMode.next()
            
            DispatchQueue.main.async {
                // TODO: Animation.
                let image: UIImage
                
                switch flashMode {
                case .flashOff:
                    image = UIImage(named: "flashOff.png")!
                case .flashOn:
                    image = UIImage(named: "flashOn.png")!
                case .flashAuto:
                    image = UIImage(named: "flashAuto.png")!
                }
                self.deviceFlashMode = flashMode.deviceFlashMode
                
                flashModeButton.setImage(image,
                                         for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        zoomButton.layer.cornerRadius = zoomButton.bounds.width / 2
        zoomButton.layer.borderWidth = 2
        zoomButton.layer.borderColor = UIColor.yellow.cgColor
        
        
        // Disable UI. The UI is enabled if and only if the session starts running.
        cameraButton.isEnabled = false
        //recordButton.isEnabled = false
        captureButton.isEnabled = false
        livePhotoModeButton.isEnabled = false
        flashModeButton.isHidden = true
        //depthDataDeliveryButton.isEnabled = false
        captureModeButton.isEnabled = false
        zoomButton.isHidden = true
        
        //updateFlashButton(toMode: uiFlashMode)
        
        // Set up the video preview view.
        previewView.session = session
        
        /*
         Check video authorization status. Video access is required and audio
         access is optional. If audio access is denied, audio is not recorded
         during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        /*
         Setup the capture session.
         In general it is not safe to mutate an AVCaptureSession or any of its
         inputs, outputs, or connections from multiple threads at the same time.
         
         Why not do all of this on the main queue?
         Because AVCaptureSession.startRunning() is a blocking call which can
         take a long time. We dispatch session setup to the sessionQueue so
         that the main queue isn't blocked, which keeps the UI responsive.
         */
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.tabBarController?.tabBar.barTintColor = UIColor.black
        
        captureButton.layer.cornerRadius = captureButton.bounds.width / 2
        videoRecordingIndicator.layer.cornerRadius = videoRecordingIndicator.bounds.width / 2

        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                self.addObservers()
                self.session.startRunning()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                self.removeObservers()
            }
        }
        
        super.viewWillDisappear(animated)
    }
    
    override var shouldAutorotate: Bool {
        // Disable autorotation of the interface when recording is in progress.
        if let movieFileOutput = movieFileOutput {
            return !movieFileOutput.isRecording
        }
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
            let deviceOrientation = UIDevice.current.orientation
            guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                    return
            }
            
            videoPreviewLayerConnection.videoOrientation = newVideoOrientation
        }
    }
    
    // MARK: Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    
    private var setupResult: SessionSetupResult = .success
    
    var videoDeviceInput: AVCaptureDeviceInput!
    
    // Call this on the session queue.
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        session.beginConfiguration()
        
        /*
         We do not create an AVCaptureMovieFileOutput when setting up the session because the
         AVCaptureMovieFileOutput does not support movie recording with AVCaptureSession.Preset.Photo.
         */
        session.sessionPreset = .photo
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If the back dual camera is not available, default to the back wide angle camera.
                defaultVideoDevice = backCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                /*
                 In some cases where users break their phones, the back wide angle camera is not available.
                 In this case, we should default to the front wide angle camera.
                 */
                defaultVideoDevice = frontCameraDevice
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    /*
                     Why are we dispatching this to the main queue?
                     Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
                     can only be manipulated on the main thread.
                     Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                     on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                     
                     Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                     handled by CameraViewController.viewWillTransition(to:with:).
                     */
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    
                    self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add audio input.
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        
        // Add photo output.
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
            photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
            livePhotoMode = photoOutput.isLivePhotoCaptureSupported ? .on : .off
            depthDataDeliveryMode = photoOutput.isDepthDataDeliverySupported ? .on : .off
            
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    @IBAction private func resumeInterruptedSession(_ resumeButton: UIButton) {
        sessionQueue.async {
            /*
             The session might fail to start running, e.g., if a phone or FaceTime call is still
             using audio or video. A failure to start the session running will be communicated via
             a session runtime error notification. To avoid repeatedly failing to start the session
             running, we only try to restart the session running in the session runtime error handler
             if we aren't trying to resume the session running.
             */
            self.session.startRunning()
            self.isSessionRunning = self.session.isRunning
            if !self.session.isRunning {
                DispatchQueue.main.async {
                    let message = NSLocalizedString("Unable to resume", comment: "Alert message when unable to resume the session running")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            } else {
                DispatchQueue.main.async {
                    self.resumeButton.isHidden = true
                }
            }
        }
    }
    
    @IBAction private func toggleZoomMode(_ zoombutton: UIButton) {
        if zoom == 1 {
            zoom = 2
        } else {
            zoom = 1
        }
        
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            
            do {
                try device.lockForConfiguration()
                device.videoZoomFactor = self.zoom
                device.unlockForConfiguration()
            } catch {
                print("Failed to set zoom")
            }
            
            DispatchQueue.main.async {
                self.zoomButton.setTitle(String(format: "%.fx",
                                                self.zoom),
                                         for: .normal)
            }
        }
    }
    
    @IBAction private func toggleCaptureMode(_ cameraModeButton: UIButton) {
        cameraModeButton.isEnabled = false
        captureButton.isEnabled = false
        zoomButton.isHidden = true
        
        let cameraMode = self.captureMode.next()
        
        cameraModeButton.setImage(UIImage(named: cameraMode.imageName),
                                  for: .normal)

        switch cameraMode {
        case .photo:
            videoRecordingIndicator.backgroundColor = UIColor.white
            
            sessionQueue.async {
                /*
                 Remove the AVCaptureMovieFileOutput from the session because movie recording is
                 not supported with AVCaptureSession.Preset.Photo. Additionally, Live Photo
                 capture is not supported when an AVCaptureMovieFileOutput is connected to the session.
                 */
                self.session.beginConfiguration()
                self.session.removeOutput(self.movieFileOutput!)
                self.session.sessionPreset = .photo
                
                DispatchQueue.main.async {
                    cameraModeButton.isEnabled = true
                }
                
                self.movieFileOutput = nil
                
                if self.photoOutput.isLivePhotoCaptureSupported {
                    self.photoOutput.isLivePhotoCaptureEnabled = true
                    
                    DispatchQueue.main.async {
                        self.livePhotoModeButton.isEnabled = true
                        self.livePhotoModeButton.isHidden = false
                    }
                }
                
                if self.photoOutput.isDepthDataDeliverySupported {
                    self.photoOutput.isDepthDataDeliveryEnabled = true
                    
                    DispatchQueue.main.async {
                        //self.depthDataDeliveryButton.isHidden = false
                        //self.depthDataDeliveryButton.isEnabled = true
                    }
                }
                
                self.session.commitConfiguration()
                
                DispatchQueue.main.async {
                    self.captureButton.isEnabled = true
                    self.zoomButton.isHidden = false
                }
            }
        case .video:
            videoRecordingIndicator.backgroundColor = UIColor.red
            livePhotoModeButton.isHidden = true
            //depthDataDeliveryButton.isHidden = true
            
            sessionQueue.async {
                let movieFileOutput = AVCaptureMovieFileOutput()
                
                if self.session.canAddOutput(movieFileOutput) {
                    self.session.beginConfiguration()
                    self.session.addOutput(movieFileOutput)
                    self.session.sessionPreset = .high
                    if let connection = movieFileOutput.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    self.session.commitConfiguration()
                    
                    DispatchQueue.main.async {
                        self.captureModeButton.isEnabled = true
                    }
                    
                    self.movieFileOutput = movieFileOutput
                    
                    DispatchQueue.main.async {
                        self.captureButton.isEnabled = true
                        self.zoomButton.isHidden = false
                    }
                }
            }
        }
    }
    
    // MARK: Device Configuration
    
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera],
                                                                               mediaType: .video, position: .unspecified)
    
    @IBAction private func changeCamera(_ cameraButton: UIButton) {
        cameraButton.isEnabled = false
        //recordButton.isEnabled = false
        captureButton.isEnabled = false
        zoomButton.isHidden = true
        livePhotoModeButton.isEnabled = false
        captureModeButton.isEnabled = false
        
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInWideAngleCamera
            }
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    
                    if let connection = self.movieFileOutput?.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                    }
                    
                    /*
                     Set Live Photo capture and depth data delivery if it is supported. When changing cameras, the
                     `livePhotoCaptureEnabled and depthDataDeliveryEnabled` properties of the AVCapturePhotoOutput gets set to NO when
                     a video device is disconnected from the session. After the new video device is
                     added to the session, re-enable them on the AVCapturePhotoOutput if it is supported.
                     */
                    self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
                    self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    
                    self.session.commitConfiguration()
                } catch {
                    print("Error occured while creating video device input: \(error)")
                }
            }
            
            DispatchQueue.main.async {
                self.cameraButton.isEnabled = true
                //self.recordButton.isEnabled = self.movieFileOutput != nil
                self.captureButton.isEnabled = true
                self.zoomButton.isHidden = false
                self.livePhotoModeButton.isEnabled = true
                self.flashModeButton.isEnabled = true
                self.captureModeButton.isEnabled = true
                //self.depthDataDeliveryButton.isEnabled = self.photoOutput.isDepthDataDeliveryEnabled
                //self.depthDataDeliveryButton.isHidden = !self.photoOutput.isDepthDataDeliverySupported
            }
        }
    }
    
    @IBAction private func focusAndExposeTap(_ gestureRecognizer: UITapGestureRecognizer) {
        let devicePoint = previewView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: gestureRecognizer.location(in: gestureRecognizer.view))
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    // MARK: Capturing Photos
    
    private let photoOutput = AVCapturePhotoOutput()
    
    private var inProgressPhotoCaptureDelegates = [Int64: PhotoCaptureProcessor]()
    
    @IBAction private func capture(_ captureButton: UIButton) {
        switch captureMode {
        case .photo:
            capturePhoto(captureButton)
        case .video:
            toggleMovieRecording(captureButton)
        }
    }
    
    private func capturePhoto(_ captureButton: UIButton) {
        /*
         Retrieve the video preview layer's video orientation on the main queue before
         entering the session queue. We do this to ensure UI elements are accessed on
         the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            // Update the photo output's connection to match the video orientation of the video preview layer.
            if let photoOutputConnection = self.photoOutput.connection(with: .video) {
                photoOutputConnection.videoOrientation = videoPreviewLayerOrientation!
            }
            
            var photoSettings = AVCapturePhotoSettings()
            // Capture HEIF photo when supported, with flash set to auto and high resolution photo enabled.
            if  self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])                
            }
            
            if self.videoDeviceInput.device.isFlashAvailable {
                photoSettings.flashMode = self.deviceFlashMode
            }
            
            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            if self.livePhotoMode == .on && self.photoOutput.isLivePhotoCaptureSupported { // Live Photo capture is not supported in movie mode.
                let livePhotoMovieFileName = NSUUID().uuidString
                let livePhotoMovieFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((livePhotoMovieFileName as NSString).appendingPathExtension("mov")!)
                photoSettings.livePhotoMovieFileURL = URL(fileURLWithPath: livePhotoMovieFilePath)
            }
            
            if self.depthDataDeliveryMode == .on && self.photoOutput.isDepthDataDeliverySupported {
                photoSettings.isDepthDataDeliveryEnabled = true
            } else {
                photoSettings.isDepthDataDeliveryEnabled = false
            }
            
            // Use a separate object for the photo capture delegate to isolate each capture life cycle.
            let photoCaptureProcessor = PhotoCaptureProcessor(with: photoSettings, willCapturePhotoAnimation: {
                DispatchQueue.main.async {
                    self.previewView.videoPreviewLayer.opacity = 0
                    UIView.animate(withDuration: 0.25) {
                        self.previewView.videoPreviewLayer.opacity = 1
                    }
                }
            }, livePhotoCaptureHandler: { capturing in
                /*
                 Because Live Photo captures can overlap, we need to keep track of the
                 number of in progress Live Photo captures to ensure that the
                 Live Photo label stays visible during these captures.
                 */
                self.sessionQueue.async {
                    if capturing {
                        self.inProgressLivePhotoCapturesCount += 1
                    } else {
                        self.inProgressLivePhotoCapturesCount -= 1
                    }
                    
                    let inProgressLivePhotoCapturesCount = self.inProgressLivePhotoCapturesCount
                    DispatchQueue.main.async {
                        if inProgressLivePhotoCapturesCount > 0 {
                            self.capturingLivePhotoIndicator.isHidden = false
                        } else if inProgressLivePhotoCapturesCount == 0 {
                            self.capturingLivePhotoIndicator.isHidden = true
                        } else {
                            print("Error: In progress live photo capture count is less than 0")
                        }
                    }
                }
            }, completionHandler: { photoCaptureProcessor in
                // When the capture is complete, remove a reference to the photo capture delegate so it can be deallocated.
                self.sessionQueue.async {
                    self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = nil
                }
            }
            )
            
            /*
             The Photo Output keeps a weak reference to the photo capture delegate so
             we store it in an array to maintain a strong reference to this object
             until the capture is completed.
             */
            self.inProgressPhotoCaptureDelegates[photoCaptureProcessor.requestedPhotoSettings.uniqueID] = photoCaptureProcessor
            self.photoOutput.capturePhoto(with: photoSettings, delegate: photoCaptureProcessor)
        }
    }
    
    private enum LivePhotoMode {
        case on
        case off
    }
    
    private enum DepthDataDeliveryMode {
        case on
        case off
    }
    
    private var livePhotoMode: LivePhotoMode = .off
    
    @IBAction private func toggleLivePhotoMode(_ livePhotoModeButton: UIButton) {
        sessionQueue.async {
            self.livePhotoMode = (self.livePhotoMode == .on) ? .off : .on
            let livePhotoMode = self.livePhotoMode
            
            DispatchQueue.main.async {
                if livePhotoMode == .on {
                    livePhotoModeButton.tintColor = UIColor.yellow
                    //self.livePhotoModeButton.setTitle(NSLocalizedString("Live Photo Mode: On", comment: "Live photo mode button on title"), for: [])
                } else {
                    livePhotoModeButton.tintColor = UIColor.darkGray
                    //self.livePhotoModeButton.setTitle(NSLocalizedString("Live Photo Mode: Off", comment: "Live photo mode button off title"), for: [])
                }
            }
        }
    }
    
    private var depthDataDeliveryMode: DepthDataDeliveryMode = .off
    
    @IBOutlet private weak var depthDataDeliveryButton: UIButton!
    
    @IBAction func toggleDepthDataDeliveryMode(_ depthDataDeliveryButton: UIButton) {
        sessionQueue.async {
            self.depthDataDeliveryMode = (self.depthDataDeliveryMode == .on) ? .off : .on
            let depthDataDeliveryMode = self.depthDataDeliveryMode
            
            DispatchQueue.main.async {
                if depthDataDeliveryMode == .on {
                    self.depthDataDeliveryButton.setTitle(NSLocalizedString("Depth Data Delivery: On", comment: "Depth Data Delivery button on title"), for: [])
                } else {
                    self.depthDataDeliveryButton.setTitle(NSLocalizedString("Depth Data Delivery: Off", comment: "Depth Data Delivery button off title"), for: [])
                }
            }
        }
    }
    
    private var inProgressLivePhotoCapturesCount = 0
    
    // MARK: Recording Movies
    
    private var movieFileOutput: AVCaptureMovieFileOutput?
    
    private var backgroundRecordingID: UIBackgroundTaskIdentifier?
    
    @IBOutlet private weak var recordButton: UIButton!
    
    @IBAction private func toggleMovieRecording(_ captureButton: UIButton) {
        guard let movieFileOutput = self.movieFileOutput else {
            return
        }
        
        /*
         Disable the Camera button until recording finishes, and disable
         the Record button until recording starts or finishes.
         
         See the AVCaptureFileOutputRecordingDelegate methods.
         */
        cameraButton.isEnabled = false
        //recordButton.isEnabled = false
        captureModeButton.isEnabled = false
        
        /*
         Retrieve the video preview layer's video orientation on the main queue
         before entering the session queue. We do this to ensure UI elements are
         accessed on the main thread and session configuration is done on the session queue.
         */
        let videoPreviewLayerOrientation = previewView.videoPreviewLayer.connection?.videoOrientation
        
        sessionQueue.async {
            let isRecording: Bool
            
            if !movieFileOutput.isRecording {
                if UIDevice.current.isMultitaskingSupported {
                    /*
                     Setup background task.
                     This is needed because the `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)`
                     callback is not received until AVCam returns to the foreground unless you request background execution time.
                     This also ensures that there will be time to write the file to the photo library when AVCam is backgrounded.
                     To conclude this background execution, endBackgroundTask(_:) is called in
                     `capture(_:, didFinishRecordingToOutputFileAt:, fromConnections:, error:)` after the recorded file has been saved.
                     */
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                // Update the orientation on the movie file output video connection before starting recording.
                let movieFileOutputConnection = movieFileOutput.connection(with: .video)
                movieFileOutputConnection?.videoOrientation = videoPreviewLayerOrientation!
                
                let availableVideoCodecTypes = movieFileOutput.availableVideoCodecTypes
                
                if availableVideoCodecTypes.contains(.hevc) {
                    movieFileOutput.setOutputSettings([AVVideoCodecKey: AVVideoCodecType.hevc], for: movieFileOutputConnection!)
                }
                
                // Start recording to a temporary file.
                let outputFileName = NSUUID().uuidString
                let outputFilePath = (NSTemporaryDirectory() as NSString).appendingPathComponent((outputFileName as NSString).appendingPathExtension("mov")!)
                movieFileOutput.startRecording(to: URL(fileURLWithPath: outputFilePath), recordingDelegate: self)
                isRecording = true
            } else {
                movieFileOutput.stopRecording()
                isRecording = false
            }
        }
    }
    
    func animateCaptureButtonChanges(size: CGFloat,
                                     cornerRadius: CGFloat) {
        self.videoRecordingIndicatorXConstraint.constant = size
        self.videoRecordingIndicatorYConstraint.constant = size
        
        UIView.animate(withDuration: 0.3) {
            self.videoRecordingIndicator.layer.cornerRadius = cornerRadius
            self.view.layoutIfNeeded()
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Enable the Record button to let the user stop the recording.
        DispatchQueue.main.async {
            self.captureButton.isEnabled = true
            self.zoomButton.isHidden = false
            
            let recordingSize: CGFloat = 32
            let recordingCornerRadius: CGFloat = recordingSize / 4
            
            self.animateCaptureButtonChanges(size: recordingSize,
                                             cornerRadius: recordingCornerRadius)
        }
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        /*
         Note that currentBackgroundRecordingID is used to end the background task
         associated with this recording. This allows a new recording to be started,
         associated with a new UIBackgroundTaskIdentifier, once the movie file output's
         `isRecording` property is back to false — which happens sometime after this method
         returns.
         
         Note: Since we use a unique file path for each recording, a new recording will
         not overwrite a recording currently being saved.
         */
        func cleanUp() {
            let path = outputFileURL.path
            if FileManager.default.fileExists(atPath: path) {
                do {
                    try FileManager.default.removeItem(atPath: path)
                } catch {
                    print("Could not remove file at url: \(outputFileURL)")
                }
            }
            
            if let currentBackgroundRecordingID = backgroundRecordingID {
                backgroundRecordingID = UIBackgroundTaskInvalid
                
                if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            }
        }
        
        var success = true
        
        if error != nil {
            print("Movie file finishing error: \(String(describing: error))")
            success = (((error! as NSError).userInfo[AVErrorRecordingSuccessfullyFinishedKey] as AnyObject).boolValue)!
        }
        
        if success {
            // Check authorization status.
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    // Save the movie file to the photo library and cleanup.
                    PHPhotoLibrary.shared().performChanges({
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let creationRequest = PHAssetCreationRequest.forAsset()
                        creationRequest.addResource(with: .video, fileURL: outputFileURL, options: options)
                    }, completionHandler: { success, error in
                        if !success {
                            print("Could not save movie to photo library: \(String(describing: error))")
                        }
                        cleanUp()
                    }
                    )
                } else {
                    cleanUp()
                }
            }
        } else {
            cleanUp()
        }
        
        // Enable the Camera and Record buttons to let the user switch camera and start another recording.
        DispatchQueue.main.async {
            // Only enable the ability to change camera if the device has more than one camera.
            self.cameraButton.isEnabled = self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
            self.captureModeButton.isEnabled = true
            
            let regularSize: CGFloat = 48
            let regularCornerRadius: CGFloat = regularSize / 2
            
            self.animateCaptureButtonChanges(size: regularSize,
                                             cornerRadius: regularCornerRadius)
        }
    }
    
    // MARK: KVO and Notifications
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    private func addObservers() {
        let keyValueObservation = session.observe(\.isRunning, options: .new) { _, change in
            guard let isSessionRunning = change.newValue else { return }
            let isLivePhotoCaptureSupported = self.photoOutput.isLivePhotoCaptureSupported
            let isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureEnabled
            let isDepthDeliveryDataSupported = self.photoOutput.isDepthDataDeliverySupported
            let isDepthDeliveryDataEnabled = self.photoOutput.isDepthDataDeliveryEnabled
            let isFlashAvailable = self.videoDeviceInput.device.isFlashAvailable
            
            DispatchQueue.main.async {
                // Only enable the ability to change camera if the device has more than one camera.
                self.cameraButton.isEnabled = isSessionRunning && self.videoDeviceDiscoverySession.uniqueDevicePositionsCount > 1
                //self.recordButton.isEnabled = isSessionRunning && self.movieFileOutput != nil
                self.captureButton.isEnabled = isSessionRunning
                self.zoomButton.isHidden = !isSessionRunning
                self.captureModeButton.isEnabled = isSessionRunning
                self.livePhotoModeButton.isEnabled = isSessionRunning && isLivePhotoCaptureEnabled
                self.livePhotoModeButton.isHidden = !(isSessionRunning && isLivePhotoCaptureSupported)
                self.flashModeButton.isHidden = !(isSessionRunning && isFlashAvailable)
                //self.depthDataDeliveryButton.isEnabled = isSessionRunning && isDepthDeliveryDataEnabled
                //self.depthDataDeliveryButton.isHidden = !(isSessionRunning && isDepthDeliveryDataSupported)
            }
        }
        keyValueObservations.append(keyValueObservation)
        
        NotificationCenter.default.addObserver(self, selector: #selector(subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionRuntimeError), name: .AVCaptureSessionRuntimeError, object: session)
        
        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self, selector: #selector(sessionWasInterrupted), name: .AVCaptureSessionWasInterrupted, object: session)
        NotificationCenter.default.addObserver(self, selector: #selector(sessionInterruptionEnded), name: .AVCaptureSessionInterruptionEnded, object: session)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        
        print("Capture session runtime error: \(error)")
        
        /*
         Automatically try to restart the session running if media services were
         reset and the last start running succeeded. Otherwise, enable the user
         to try to resume the session running.
         */
        if error.code == .mediaServicesWereReset {
            sessionQueue.async {
                if self.isSessionRunning {
                    self.session.startRunning()
                    self.isSessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async {
                        self.resumeButton.isHidden = false
                    }
                }
            }
        } else {
            resumeButton.isHidden = false
        }
    }
    
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios we want to enable the user to resume the session running.
         For example, if music playback is initiated via control center while
         using AVCam, then the user can let AVCam resume
         the session running, which will stop music playback. Note that stopping
         music playback in control center will not automatically resume the session
         running. Also note that it is not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            var showResumeButton = false
            
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                showResumeButton = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Simply fade-in a label to inform the user that the camera is unavailable.
                cameraUnavailableLabel.alpha = 0
                cameraUnavailableLabel.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.cameraUnavailableLabel.alpha = 1
                }
            }
            
            if showResumeButton {
                // Simply fade-in a button to enable the user to try to resume the session running.
                resumeButton.alpha = 0
                resumeButton.isHidden = false
                UIView.animate(withDuration: 0.25) {
                    self.resumeButton.alpha = 1
                }
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        
        if !resumeButton.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.resumeButton.alpha = 0
            }, completion: { _ in
                self.resumeButton.isHidden = true
            }
            )
        }
        if !cameraUnavailableLabel.isHidden {
            UIView.animate(withDuration: 0.25,
                           animations: {
                            self.cameraUnavailableLabel.alpha = 0
            }, completion: { _ in
                self.cameraUnavailableLabel.isHidden = true
            }
            )
        }
    }
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}

extension AVCaptureDevice.DiscoverySession {
    var uniqueDevicePositionsCount: Int {
        var uniqueDevicePositions: [AVCaptureDevice.Position] = []
        
        for device in devices {
            if !uniqueDevicePositions.contains(device.position) {
                uniqueDevicePositions.append(device.position)
            }
        }
        
        return uniqueDevicePositions.count
    }
}



//
//  CameraViewController.swift
//  SPV
//
//  Created by dlatheron on 23/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//
/*
import AVFoundation
import Foundation
import Photos
import UIKit
import MediaPlayer

class CameraViewController : UIViewController {
    @IBOutlet fileprivate weak var captureButton: UIButton!
    @IBOutlet fileprivate weak var recordIndicator: UIView!
    @IBOutlet fileprivate weak var zoomButton: UIButton!
    @IBOutlet fileprivate weak var selfTimerCountdown: UILabel!
    @IBOutlet fileprivate weak var selfTimerMenu: UIView!
    @IBOutlet fileprivate weak var selfTimer5Seconds: UIButton!
    @IBOutlet fileprivate weak var selfTimer10Seconds: UIButton!
    @IBOutlet fileprivate weak var selfTimer20Seconds: UIButton!
    
    @IBOutlet fileprivate weak var capturePreviewView: UIView!
    @IBOutlet fileprivate weak var flashButton: UIButton!
    @IBOutlet fileprivate weak var selfTimerButton: UIButton!
    @IBOutlet fileprivate weak var rotateCameraButton: UIButton!
    @IBOutlet fileprivate weak var modeButton: UIButton!
    
    @IBOutlet fileprivate weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var bottomToolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topToolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var selfTimerToolbarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomToolbarYOffsetConstraint: NSLayoutConstraint!
    
    let jpegPhotoImageQuality: CGFloat = 0.8
    
    enum Colours {
        case selected
        case unselected
        
        var value: UIColor {
            get {
                switch self {
                case .selected:
                    return UIColor(red: 0x44/255, green: 0x55/255, blue: 1, alpha: 1)
                case .unselected:
                    return UIColor.white
                }
            }
        }
        
        static func colourIf(selected isSelected: Bool) -> UIColor {
            return isSelected ?
                Colours.selected.value :
                Colours.unselected.value
        }
    }
    
    enum CameraMode {
        case photo
        case video
        case livePhoto
        
        var imageName: String {
            get {
                switch self {
                case .photo: return "cameraInv.png"
                case .video: return "video.png"
                case .livePhoto: return "livePhoto.png"
                }
            }
        }
        
        var captureMode: CameraController.CaptureMode {
            get {
                switch self {
                case .photo: return .photo
                case .video: return .video
                case .livePhoto: return .livePhoto
                }
            }
        }
        
        mutating func next() {
            switch self {
            case .photo:
                self = .video
            case .video:
                self = .livePhoto
            case .livePhoto:
                self = .photo
            }
        }
    }
    
    enum FlashMode {
        case flashAuto
        case flashOn
        case flashOff
        
        var imageName: String {
            get {
                switch self {
                case .flashAuto: return "flashAuto.png"
                case .flashOn: return "flashOn.png"
                case .flashOff: return "flashOff.png"
                }
            }
        }
        
        var avFlashMode: AVCaptureDevice.FlashMode {
            get {
                switch self {
                case .flashAuto: return AVCaptureDevice.FlashMode.auto
                case .flashOn: return AVCaptureDevice.FlashMode.on
                case .flashOff: return AVCaptureDevice.FlashMode.off
                }
            }
        }
        
        mutating func next() {
            switch self {
            case .flashAuto:
                self = .flashOn
            case .flashOn:
                self = .flashOff
            case .flashOff:
                self = .flashAuto
            }
        }
    }
    
    enum SelfTimer {
        case off
        case on
        
        var active: Bool {
            get {
                return self == .on
            }
        }
        
        mutating func next() {
            switch self {
            case .off:
                self = .on
            case .on:
                self = .off
            }
        }
    }
    
    enum CameraRotation {
        case rear
        case front
        
        var active: Bool {
            get {
                return self == .front
            }
        }
        
        var cameraPosition: CameraController.CameraPosition {
            get {
                switch self {
                case .rear: return CameraController.CameraPosition.rear
                case .front: return CameraController.CameraPosition.front
                }
            }
        }
        
        mutating func next() {
            switch self {
            case .rear:
                self = .front
            case .front:
                self = .rear
            }
        }
    }
    
    let cameraController = CameraController()
    let fakeCameraBackground = UIImageView()
    
    var cameraMode: CameraMode = .livePhoto
    var flashMode: FlashMode = .flashAuto
    var selfTimer: SelfTimer = .off
    var cameraRotation: CameraRotation = .rear
    var selfTimerMenuVisible: Bool = false
    var selfTimerInterval: Int = 5
    var capturing: Bool = false
    
    var timerCountdown: Int = 0
    var timer: Timer? = nil
        
    class Timings {
        static let selfTimerMenuShowDuration = 0.3
        static let selfTimerMenuHideDuration = 0.3
        static let selfTimerMenuHideDelay = 0.2
    }
    
    @IBAction func toggleCameraMode(_ sender: Any) {
        cameraMode.next()
        updateModeButton(toMode: cameraMode)
        try? self.cameraController.configure(camera: cameraRotation.cameraPosition,
                                             mode: cameraMode.captureMode)
    }
    
    func updateFlashButton(toMode flashMode: FlashMode) {
        if cameraController.hasFlash {
            flashButton.setImage(UIImage(named: flashMode.imageName),
                                 for: .normal)
        } else {
            flashButton.setImage(UIImage(named: FlashMode.flashOff.imageName),
                                 for: .normal)
        }
    }

    @IBAction func toggleFlashMode(_ sender: Any) {
        flashMode.next()
        updateFlashButton(toMode: flashMode)
        cameraController.flashMode = flashMode.avFlashMode
    }
    
    func updateModeButton(toMode cameraMode: CameraMode) {
    modeButton.setImage(UIImage(named: cameraMode.imageName), for: .normal)
    }
    
    @IBAction func toggleSelfTimer(_ sender: Any,
                                   forEvent event: UIEvent) {
        func nextSelfTimerMode() {
            selfTimer.next()
            updateSelfTimerButton(toMode: selfTimer)
        }
        
        func displaySelfTimerMenu() {
            selfTimer = .on
            updateSelfTimerButton(toMode: selfTimer)
            showSelfTimerMenu()
        }
        
        guard let touch = event.allTouches?.first else {
            nextSelfTimerMode()
            return
        }
        
        let forceTouchEnabled = traitCollection.forceTouchCapability == .available
        print("Available: \(forceTouchEnabled), Force: \(touch.force)")
        
        if forceTouchEnabled && touch.force > 1.0 {
            displaySelfTimerMenu()
        } else if touch.tapCount == 0 {
            displaySelfTimerMenu()
        } else if touch.tapCount == 1 {
            nextSelfTimerMode()
        }
    }
    
    func setSelfTimerButtonState(selfTimerInterval: Int) {
        let buttons = [
            (interval:  5, button: selfTimer5Seconds),
            (interval: 10, button: selfTimer10Seconds),
            (interval: 20, button: selfTimer20Seconds),
        ]
        
        for button in buttons {
            button.button.tintColor = Colours.colourIf(selected: button.interval == selfTimerInterval)
        }
    }
    
    func showSelfTimerMenu() {
        if selfTimerMenuVisible {
            return
        }
        
        setSelfTimerButtonState(selfTimerInterval: selfTimerInterval)
        
        selfTimerMenu.alpha = 0
        selfTimerMenu.isHidden = false
        
        UIView.animate(withDuration: Timings.selfTimerMenuShowDuration,
                       animations: {
            self.selfTimerMenu.alpha = 1
        })
        
        selfTimerMenuVisible = true
    }
    
    func hideSelfTimerMenu() {
        if !selfTimerMenuVisible {
            return
        }
        
        UIView.animate(withDuration: Timings.selfTimerMenuHideDuration,
                       delay: Timings.selfTimerMenuHideDelay,
                       animations: {
            self.selfTimerMenu.alpha = 0.0
        }) { (completed) in
            if completed {
                self.selfTimerMenu.isHidden = true
            }
        }

        selfTimerMenuVisible = false
    }
    
    func updateSelfTimerButton(toMode selfTimer: SelfTimer) {
        if selfTimer.active {
            selfTimerButton.isSelected = true
        } else {
            selfTimerButton.isSelected = false
        }
//        if selfTimer.active {
//            selfTimerButton.tintColor = Colours.selected.value
//            selfTimerButton.setImage(UIImage(named: 'timerInv'), for: .selected)
//        } else {
//            selfTimerButton.tintColor = Colours.unselected.value
//            hideSelfTimerMenu()
//        }
    }
    
    func updateSelfTimerTimings(to seconds: Int) {
        selfTimerInterval = seconds
        setSelfTimerButtonState(selfTimerInterval: selfTimerInterval)
        hideSelfTimerMenu()
    }
    
    @IBAction func setSelfTimerTo5Seconds(_ sender: Any) {
        updateSelfTimerTimings(to: 5)
    }
    
    @IBAction func setSelfTimerTo10Seconds(_ sender: Any) {
        updateSelfTimerTimings(to: 10)
    }
    
    @IBAction func setSelfTimerTo20Seconds(_ sender: Any) {
        updateSelfTimerTimings(to: 20)
    }
    
    @IBAction func setZoom(_ sender: Any) {
        if cameraController.zoom == 1 {
            cameraController.zoom = 2
        } else {
            cameraController.zoom = 1
        }
        
        zoomButton.setTitle(String(format: "%.1fx",
                                   cameraController.zoom),
                            for: .normal)
    }

    @IBAction func rotateCamera(_ sender: Any) {
        cameraRotation.next()
        
        cameraSwitchAnimation(forView: capturePreviewView,
                              toCameraRotation: cameraRotation)
    }
    
    @IBAction func capture(_ sender: Any) {
        if capturing {
            stopCapturing()
        } else if selfTimer.active {
            if timer == nil {
                captureMedia(after: selfTimerInterval)
            } else {
                cancelSelfTimer()
            }
        } else {
            captureMedia()
        }
    }
    
    func cancelSelfTimer() {
        timer?.invalidate()
        timer = nil
        
        hideTimerCountdown()
    }
    
    func updateCountdown(_ countdown: Int) {
        if countdown == 0 {
            selfTimerCountdown.text = "Smile!"
        } else {
            selfTimerCountdown.text = "\(countdown)"
        }
    }
    
    func showTimerCountdown() {
        selfTimerCountdown.alpha = 0
        selfTimerCountdown.isHidden = false
        
        UIView.animate(withDuration: 0.3,
                       animations: {
            self.selfTimerCountdown.alpha = 1
        }, completion: { (completed) in
            if completed {
                self.timer = Timer.scheduledTimer(timeInterval: 1,
                                                  target:self,
                                                  selector:    #selector(self.updateSelfTimerCountdown),
                                                  userInfo: nil,
                                                  repeats: true)
            }
        })
    }
    
    func hideTimerCountdown() {
        UIView.animate(withDuration: 0.3,
                       animations: {
            self.selfTimerCountdown.alpha = 0
        }, completion: { (completed) in
            if completed {
                self.selfTimerCountdown.isHidden = true
                self.selfTimerCountdown.alpha = 1
            }
        })
    }
    
    func captureMedia(after seconds: Int) {
        timerCountdown = seconds
        updateCountdown(timerCountdown)
        
        showTimerCountdown()
    }
    
    func stopCapturing() {
        switch cameraMode {
        case .video:
            cameraController.stopCapturingVideo()
        default:
            print("")
        }
    }
    
    @objc func updateSelfTimerCountdown() {
        timerCountdown = timerCountdown - 1
        updateCountdown(timerCountdown)

        if (timerCountdown == 0) {
            cancelSelfTimer()

            captureMedia()
        }
    }
    
    func shutterAnimation(forView view: UIView) {
        let shutterAnimation = CATransition.init()
        shutterAnimation.duration = 0.6
        shutterAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        shutterAnimation.type = "cameraIris"
        shutterAnimation.setValue("cameraIris",
                                  forKey: "cameraIris")
        
        let shutterLayer = CALayer.init()
        shutterLayer.bounds = view.bounds
        view.layer.addSublayer(shutterLayer)
        view.layer.add(shutterAnimation,
                       forKey: "cameraIris")
    }
    
    func cameraSwitchAnimation(forView view: UIView,
                               toCameraRotation cameraRotation: CameraRotation) {
        // TODO: Fix the bug whereby the new camera view is displayed BEFORE the flip happens.
        let flipAnimation = CATransition.init()
        flipAnimation.duration = 0.5
        flipAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        flipAnimation.type = "oglFlip"
        
        switch cameraRotation {
        case .front:
            flipAnimation.subtype = kCATransitionFromRight
        case .rear:
            flipAnimation.subtype = kCATransitionFromLeft
        }
        
        let flipLayer = CALayer.init()
        flipLayer.bounds = view.bounds
        view.layer.addSublayer(flipLayer)
        view.layer.add(flipAnimation,
                       forKey: "oglFlip")
        
        UIView.animate(withDuration: flipAnimation.duration / 2) {
            switch cameraRotation {
            case .front:
                try? self.cameraController.configure(camera: CameraRotation.front.cameraPosition,
                                                       mode: self.cameraMode.captureMode)
            case .rear:
                try? self.cameraController.configure(camera: CameraRotation.rear.cameraPosition,
                                                       mode: self.cameraMode.captureMode)
            }
            
            if self.capturePreviewView.subviews.count > 0 {
                self.setFakeCameraBackground()
            }
        }
    }
    
    func getURLForDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)
        
        return paths[0] as URL
    }
    
    func createLocalFileURL(filename: String) -> URL {
        let documentsDirectoryURL = getURLForDocumentsDirectory()
        let localFileURL = documentsDirectoryURL.appendingPathComponent(filename)
        
        return localFileURL
    }
    
    func saveImageToLocalFile(image: UIImage,
                              url: URL) throws {
        if let data = UIImageJPEGRepresentation(image, jpegPhotoImageQuality) {
            try? data.write(to: url,
                            options: [ .atomic, .completeFileProtection ])
        }
    }
    
    func saveImageToCameraRoll(image: UIImage) throws {
        try? PHPhotoLibrary.shared().performChangesAndWait {
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }
    }
    
    func captureMedia() {
        print("Capturing media")
        
        capturing = true
        switch cameraMode {
        case .photo:
            // TODO: Improve the shutter animation.
            shutterAnimation(forView: capturePreviewView)
            
            cameraController.captureImage { (image, error) in
                self.capturing = false

                guard
                    let image = image
                else {
                    print(error ?? "Image capture error")
                    return
                }
                
                if let localFileURL = MediaManager.GetNextFileURL(filenamePrefix: "CameraPhoto-",
                                                                  numberOfDigits: 6,
                                                                  filenamePostfix: ".jpg") {
                    try? self.saveImageToLocalFile(image: image,
                                                   url: localFileURL)
                    
                    _ = MediaManager.shared.addMedia(url: localFileURL)
                } else {
                    print("Too many existing photos")
                }
                //try? self.saveImageToCameraRoll(image: image)
            }

        case .video:
            // TODO: Activate the record indicator...
            styleRecordIndicator(on: capturing)
            
            cameraController.captureVideo { (videoURL, error) in
                self.capturing = false
                self.styleRecordIndicator(on: self.capturing)

                guard
                    let videoURL = videoURL
                else {
                    print(error ?? "Video capture error")
                    return
                }

                _ = MediaManager.shared.addMedia(url: videoURL)
            }

        case .livePhoto:
            cameraController.captureLivePhoto { (livePhoto, error) in
                self.capturing = false
                
                guard
                    let livePhoto = livePhoto
                else {
                    print(error ?? "Live Photo capture error")
                    return
                }
                
                _ = MediaManager.shared.addMedia(url: livePhoto.directoryURL)
            }
        }
    }
}

extension CameraViewController {
    func positionBottomToolbar() {
        let navBarHeight: CGFloat = UIScreen.main.isLandscape ? 30 : 44
        //let tabBarHeight: CGFloat = UIScreen.main.isLandscape ? 32 : 49
        
        bottomToolbarHeightConstraint.constant = UIScreen.main.isLandscape ? 32 + 16 : 44 + 16
        topToolbarHeightConstraint.constant = UIScreen.main.isLandscape ? 78 : 68
        selfTimerToolbarHeightConstraint.constant = navBarHeight
        //bottomToolbarYOffsetConstraint.constant = tabBarHeight
        
        self.view.setNeedsUpdateConstraints()
        self.view.setNeedsLayout()
        self.view.setNeedsDisplay()
    }
    
//    override func viewWillTransition(to size: CGSize,
//                                     with coordinator: UIViewControllerTransitionCoordinator) {
//        guard
//            tabBarController?.selectedViewController === self
//        else {
//                return
//        }
//
//        super.viewWillTransition(to: size,
//                                 with: coordinator)
//        
//        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
//            self.positionBottomToolbar()
//            self.cameraController.setPreviewOrientation()
//            self.view.layer.shouldRasterize = true
//        }) { (context: UIViewControllerTransitionCoordinatorContext) in
//            self.view.layer.shouldRasterize = false
//            self.positionBottomToolbar()
//        }
//    }
}

extension CameraViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CameraViewController {
    func setFakeCameraBackground() {
        let fakeCameraImageName: String
        switch cameraRotation {
        case .front: fakeCameraImageName = "fakeCameraBackgroundFront"
        case .rear: fakeCameraImageName = "fakeCameraBackgroundRear"
        }
        fakeCameraBackground.image = UIImage(named: fakeCameraImageName)
    }
    
    override func viewDidLoad() {
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                    self.fakeCameraBackground.frame = UIScreen.main.bounds
                    self.fakeCameraBackground.contentMode = .scaleAspectFill
                    self.fakeCameraBackground.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
                    self.capturePreviewView.insertSubview(self.fakeCameraBackground, at: 0)
                    self.setFakeCameraBackground()
                    self.cameraController.setPreviewOrientation()
                } else {
                    try? self.cameraController.displayPreview(on: self.capturePreviewView)
                }
            }
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        func styleZoomButton() {
            zoomButton.layer.borderColor = zoomButton.tintColor.cgColor
            zoomButton.layer.borderWidth = 2
            zoomButton.layer.cornerRadius = min(zoomButton.frame.width, captureButton.frame.height) / 2
        }
        
        super.viewDidLoad()
        
        positionBottomToolbar()
        
        updateFlashButton(toMode: flashMode)
        updateModeButton(toMode: cameraMode)
        updateSelfTimerButton(toMode: selfTimer)

        styleCaptureButton()
        styleZoomButton()
        styleRecordIndicator(on: false)
        configureCameraController()
    }
    
    func styleRecordIndicator(on: Bool) {
        if on {
            recordIndicator.layer.borderColor = UIColor.black.cgColor
            recordIndicator.layer.borderWidth = 1
            recordIndicator.layer.cornerRadius = min(recordIndicator.frame.width, recordIndicator.frame.height) / 2
            recordIndicator.backgroundColor = UIColor.red
            
            recordIndicator.isHidden = false
        } else {
            recordIndicator.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIViewController.attemptRotationToDeviceOrientation()

        self.cameraController.setPreviewOrientation()
        
        self.tabBarController?.tabBar.barTintColor = UIColor.black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }
}
 
 */
