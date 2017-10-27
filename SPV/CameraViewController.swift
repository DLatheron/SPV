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

class CameraViewController : UIViewController {
    @IBOutlet fileprivate weak var captureButton: UIButton!
    @IBOutlet fileprivate weak var selfTimerCountdown: UILabel!
    @IBOutlet fileprivate weak var selfTimerMenu: UIToolbar!
    @IBOutlet fileprivate weak var selfTimer5Seconds: UIBarButtonItem!
    @IBOutlet fileprivate weak var selfTimer10Seconds: UIBarButtonItem!
    @IBOutlet fileprivate weak var selfTimer20Seconds: UIBarButtonItem!
    
    @IBOutlet fileprivate weak var capturePreviewView: UIView!
    @IBOutlet fileprivate weak var flashButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var selfTimerButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var rotateCameraButton: UIBarButtonItem!
    @IBOutlet fileprivate weak var modeButton: UIBarButtonItem!
    
    enum Colours {
        case selected
        case unselected
        
        var value: UIColor {
            get {
                switch self {
                case .selected:
                    return UIColor(red: 0x99/255, green: 0xcc/255, blue: 1, alpha: 1)
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
        case camera
        case video
        
        var imageName: String {
            get {
                switch self {
                case .camera: return "cameraInv.png"
                case .video: return "video.png"
                }
            }
        }
        
        mutating func next() {
            switch self {
            case .camera:
                self = .video
            case .video:
                self = .camera
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
    var cameraMode: CameraMode = .camera
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
        flashButton.image = UIImage(named: flashMode.imageName)
    }

    @IBAction func toggleFlashMode(_ sender: Any) {
        flashMode.next()
        updateFlashButton(toMode: flashMode)
        cameraController.flashMode = flashMode.avFlashMode
    }
    
    func updateModeButton(toMode cameraMode: CameraMode) {
        modeButton.image = UIImage(named: cameraMode.imageName)
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
            self.selfTimerMenu.alpha = 1.0
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
            selfTimerButton.tintColor = Colours.selected.value
        } else {
            selfTimerButton.tintColor = Colours.unselected.value
            hideSelfTimerMenu()
        }
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
        updateRotateCameraButton(toMode: cameraRotation)
        
        switch cameraRotation {
        case .front:
            try? cameraController.switchToFrontCamera()
        case .rear:
            try? cameraController.switchToRearCamera()
        }
    }
    
    func updateRotateCameraButton(toMode cameraRotation: CameraRotation) {
        if cameraRotation.active {
            rotateCameraButton.tintColor = Colours.selected.value
        } else {
            rotateCameraButton.tintColor = Colours.unselected.value
        }
    }
    
    @IBAction func capture(_ sender: Any) {
        if selfTimer.active {
            if timer == nil {
                captureImage(after: selfTimerInterval)
            } else {
                cancelSelfTimer()
            }
        } else {
            captureImage()
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
    
    func captureImage(after seconds: Int) {
        timerCountdown = seconds
        updateCountdown(timerCountdown)
        
        showTimerCountdown()
    }
    
    @objc func updateSelfTimerCountdown() {
        timerCountdown = timerCountdown - 1
        updateCountdown(timerCountdown)

        if (timerCountdown == 0) {
            cancelSelfTimer()

            captureImage()
        }
    }
    
    func captureImage() {
        print("Capturing image")
        
        // TODO: Video capture...
        // TODO: The capturing to a local file...
        cameraController.captureImage { (image, error) in
            guard let image = image else {
                print(error ?? "Image capture error")
                return
            }
            
            try? PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }
        }
    }
}

extension CameraViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CameraViewController {
    override func viewDidLoad() {
        func configureCameraController() {
            cameraController.prepare {(error) in
                if let error = error {
                    print(error)
                }
                
                try? self.cameraController.displayPreview(on: self.capturePreviewView)
            }
        }
        
        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        super.viewDidLoad()
        
        updateFlashButton(toMode: flashMode)
        updateModeButton(toMode: cameraMode)
        updateSelfTimerButton(toMode: selfTimer)
        updateRotateCameraButton(toMode: cameraRotation)

        styleCaptureButton()
        configureCameraController()
    }
}
