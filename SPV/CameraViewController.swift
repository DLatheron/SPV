//
//  CameraViewController.swift
//  SPV
//
//  Created by dlatheron on 23/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import AVFoundation
import Foundation
import Photos
import UIKit
import MediaPlayer

class CameraViewController : UIViewController {
    @IBOutlet fileprivate weak var captureButton: UIButton!
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
    
    var cameraMode: CameraMode = .photo
    var flashMode: FlashMode = .flashAuto
    var selfTimer: SelfTimer = .off
    var cameraRotation: CameraRotation = .rear
    var selfTimerMenuVisible: Bool = false
    var selfTimerInterval: Int = 5
    
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
    

    @IBAction func rotateCamera(_ sender: Any) {
        cameraRotation.next()
        
        cameraSwitchAnimation(forView: capturePreviewView,
                              toCameraRotation: cameraRotation)
    }
    
    @IBAction func capture(_ sender: Any) {
        if selfTimer.active {
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
                try? self.cameraController.configure(cameraPosition: CameraRotation.front.cameraPosition,
                                                     captureMode: self.cameraMode.captureMode)
            case .rear:
                try? self.cameraController.configure(cameraPosition: CameraRotation.rear.cameraPosition,
                                                     captureMode: self.cameraMode.captureMode)
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
        
        switch cameraMode {
        case .photo:
            // TODO: Improve the shutter animation.
            shutterAnimation(forView: capturePreviewView)
            
            cameraController.captureImage { (image, error) in
                guard let image = image else {
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
            
            cameraController.captureVideo { (video, error) in
                print("Video Support Not Yet Added")
            }

        case .livePhoto:
            print("Live Photo Support Not Yet Added")
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
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        guard
            tabBarController?.selectedViewController === self
        else {
                return
        }

        super.viewWillTransition(to: size,
                                 with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            self.positionBottomToolbar()
            self.cameraController.setPreviewOrientation()
            self.view.layer.shouldRasterize = true
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.view.layer.shouldRasterize = false
            self.positionBottomToolbar()
        }
    }
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
        
        super.viewDidLoad()
        
        positionBottomToolbar()
        
        updateFlashButton(toMode: flashMode)
        updateModeButton(toMode: cameraMode)
        updateSelfTimerButton(toMode: selfTimer)

        styleCaptureButton()
        configureCameraController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.cameraController.setPreviewOrientation()
        
        self.tabBarController?.tabBar.barTintColor = UIColor.black
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.tabBarController?.tabBar.barTintColor = UIColor.white
    }
}
