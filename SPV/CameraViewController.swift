//
//  CameraViewController.swift
//  SPV
//
//  Created by dlatheron on 23/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class CameraViewController : UIViewController {
    @IBOutlet fileprivate var captureButton: UIButton!

    @IBOutlet weak var flashButton: UIBarButtonItem!
    @IBOutlet weak var selfTimerButton: UIBarButtonItem!
    @IBOutlet weak var rotateCameraButton: UIBarButtonItem!
    @IBOutlet weak var modeButton: UIBarButtonItem!
    
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
        case fiveSeconds
        
        var active: Bool {
            get {
                return self == .fiveSeconds
            }
        }
        
        mutating func next() {
            switch self {
            case .off:
                self = .fiveSeconds
            case .fiveSeconds:
                self = .off
            }
        }
    }
    
    enum CameraRotation {
        case back
        case front
        
        var active: Bool {
            get {
                return self == .front
            }
        }
        
        mutating func next() {
            switch self {
            case .back:
                self = .front
            case .front:
                self = .back
            }
        }
    }
    
    var cameraMode: CameraMode = .camera
    var flashMode: FlashMode = .flashAuto
    var selfTimer: SelfTimer = .off
    var cameraRotation: CameraRotation = .back
    
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
    }
    
    func updateModeButton(toMode cameraMode: CameraMode) {
        modeButton.image = UIImage(named: cameraMode.imageName)
    }
    
    @IBAction func toggleSelfTimer(_ sender: Any) {
        selfTimer.next()
        updateSelfTimerButton(toMode: selfTimer)
    }
    
    func updateSelfTimerButton(toMode selfTimer: SelfTimer) {
        if selfTimer.active {
            selfTimerButton.tintColor = Colours.selected.value
        } else {
            selfTimerButton.tintColor = Colours.unselected.value
        }
    }
    
    @IBAction func rotateCamera(_ sender: Any) {
        cameraRotation.next()
        updateRotateCameraButton(toMode: cameraRotation)
    }
    
    func updateRotateCameraButton(toMode cameraRotation: CameraRotation) {
        if cameraRotation.active {
            rotateCameraButton.tintColor = Colours.selected.value
        } else {
            rotateCameraButton.tintColor = Colours.unselected.value
        }
    }
    
    @IBAction func capture(_ sender: Any) {
        // TODO: The capturing...
    }
}

extension CameraViewController {
    
}

extension CameraViewController {
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension CameraViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateFlashButton(toMode: flashMode)
        updateModeButton(toMode: cameraMode)
        updateSelfTimerButton(toMode: selfTimer)
        updateRotateCameraButton(toMode: cameraRotation)

        func styleCaptureButton() {
            captureButton.layer.borderColor = UIColor.black.cgColor
            captureButton.layer.borderWidth = 2
            
            captureButton.layer.cornerRadius = min(captureButton.frame.width, captureButton.frame.height) / 2
        }
        
        styleCaptureButton()
        
    }
}
