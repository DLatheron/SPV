/*
 See LICENSE.txt for this sample’s licensing information.
 
 Abstract:
 Photo capture delegate.
 */

import AVFoundation
import Photos

class PhotoCaptureProcessor: NSObject {
    private(set) var requestedPhotoSettings: AVCapturePhotoSettings
    
    private let willCapturePhotoAnimation: () -> Void
    private let livePhotoCaptureHandler: (Bool) -> Void
    private let completionHandler: (PhotoCaptureProcessor) -> Void
    private var photoData: Data?
    private var livePhotoCompanionMovieURL: URL?
    
    init(with requestedPhotoSettings: AVCapturePhotoSettings,
         willCapturePhotoAnimation: @escaping () -> Void,
         livePhotoCaptureHandler: @escaping (Bool) -> Void,
         completionHandler: @escaping (PhotoCaptureProcessor) -> Void) {
        self.requestedPhotoSettings = requestedPhotoSettings
        self.willCapturePhotoAnimation = willCapturePhotoAnimation
        self.livePhotoCaptureHandler = livePhotoCaptureHandler
        self.completionHandler = completionHandler
    }
    
    private func didFinish() {
        if let livePhotoCompanionMoviePath = livePhotoCompanionMovieURL?.path {
            if FileManager.default.fileExists(atPath: livePhotoCompanionMoviePath) {
                do {
                    try FileManager.default.removeItem(atPath: livePhotoCompanionMoviePath)
                } catch {
                    print("Could not remove file at url: \(livePhotoCompanionMoviePath)")
                }
            }
        }
        
        completionHandler(self)
    }
    
}

extension PhotoCaptureProcessor: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        if resolvedSettings.livePhotoMovieDimensions.width > 0 && resolvedSettings.livePhotoMovieDimensions.height > 0 {
            livePhotoCaptureHandler(true)
        }
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        willCapturePhotoAnimation()
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        
        if let error = error {
            print("Error capturing photo: \(error)")
        } else {
            photoData = photo.fileDataRepresentation()
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL,
                     resolvedSettings: AVCaptureResolvedPhotoSettings) {
        livePhotoCaptureHandler(false)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL,
                     duration: CMTime,
                     photoDisplayTime: CMTime,
                     resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        if error != nil {
            print("Error processing live photo companion movie: \(String(describing: error))")
            return
        }
        
        livePhotoCompanionMovieURL = outputFileURL
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings,
                     error: Error?) {
        let jpegPhotoImageQuality: CGFloat = 0.8
        
        if let error = error {
            print("Error capturing photo: \(error)")
            didFinish()
            return
        }
        
        guard
            let photoData = photoData
        else {
            print("No photo data resource")
            didFinish()
            return
        }
        
        let type = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
        if type == "public.heic" {
            if let livePhotoCompanionMovieURL = self.livePhotoCompanionMovieURL {
                //
                // Live photo
                //
                if let localDirectoryURL =
                    MediaManager.GetNextDirectoryURL(directoryPrefix: "LivePhoto-",
                                                     numberOfDigits: 6,
                                                     directoryPostfix: ".livephoto") {
                    do {
                        try FileManager.default.createDirectory(at: localDirectoryURL,
                                                                withIntermediateDirectories: true,
                                                                attributes: nil)
                        
                        let livePhoto = LivePhoto(directoryURL: localDirectoryURL)
                        
                        try photoData.write(to: livePhoto.heicURL,
                                            options: [.atomic, .completeFileProtection])
                        
                        try FileManager.default.moveItem(at: livePhotoCompanionMovieURL,
                                                         to: livePhoto.videoURL)
                        
                        if let image = UIImage(data: photoData) {
                            if let jpegData = UIImageJPEGRepresentation(image, jpegPhotoImageQuality) {
                                try jpegData.write(to: livePhoto.imageURL,
                                                   options: [.atomic, .completeFileProtection])
                            }
                        }
                        
                        _ = MediaManager.shared.addMedia(url: localDirectoryURL)
                    } catch {
                        print("Failed to write the live photo: \(error)")
                    }
                } else {
                    print("Failed to make a local directory name")
                }
            } else {
                //
                // Normal photo
                //
                if let localFileURL =
                    MediaManager.GetNextFileURL(filenamePrefix: "CameraPhoto-",
                                                numberOfDigits: 6,
                                                filenamePostfix: ".jpg") {
                    do {
                        try photoData.write(to: localFileURL,
                                            options: [.atomic, .completeFileProtection])
                        
                        _ = MediaManager.shared.addMedia(url: localFileURL)
                    } catch {
                        print("Failed to write the photo: \(error)")
                    }
                } else {
                    print("Failed to make a local filename for a photo")
                }
            }
        } else {
            print("Unexpected processed file type: \(type ?? "<no type>")")
        }
        
//        PHPhotoLibrary.requestAuthorization { status in
//            if status == .authorized {
//                PHPhotoLibrary.shared().performChanges({
//                    let options = PHAssetResourceCreationOptions()
//                    let creationRequest = PHAssetCreationRequest.forAsset()
//
//                    options.uniformTypeIdentifier = self.requestedPhotoSettings.processedFileType.map { $0.rawValue }
//                    creationRequest.addResource(with: .photo,
//                                                data: photoData,
//                                                options: options)
//
//                    if let livePhotoCompanionMovieURL = self.livePhotoCompanionMovieURL {
//                        let livePhotoCompanionMovieFileResourceOptions = PHAssetResourceCreationOptions()
//                        livePhotoCompanionMovieFileResourceOptions.shouldMoveFile = true
//
//                        creationRequest.addResource(with: .pairedVideo,
//                                                    fileURL: livePhotoCompanionMovieURL,
//                                                    options: livePhotoCompanionMovieFileResourceOptions)
//                    }
//
//                }, completionHandler: { _, error in
//                    if let error = error {
//                        print("Error occurered while saving photo to photo library: \(error)")
//                    }
//
//                    self.didFinish()
//                }
//                )
//            } else {
//                self.didFinish()
//            }
//        }
        
        didFinish()
    }
}

