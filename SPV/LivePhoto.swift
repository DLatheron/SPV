//
//  LivePhoto.swift
//  SPV
//
//  Created by dlatheron on 14/02/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit
import Photos
import MobileCoreServices

class LivePhoto : Media {
    var directoryURL: URL
    var imageURL: URL
    var videoURL: URL
    var heicURL: URL
    
    var resourceFileURLs: [URL] {
        get {
            return [
                heicURL,
                videoURL
            ]
        }
    }
    
    init(directoryURL: URL) {
        self.directoryURL = directoryURL
        
        let dirURLWithoutExtension = directoryURL.deletingPathExtension()
        let filename = dirURLWithoutExtension.lastPathComponent
        
        imageURL = URL(fileURLWithPath: directoryURL.appendingPathComponent("\(filename).jpeg").absoluteString)
        videoURL = URL(fileURLWithPath:directoryURL.appendingPathComponent("\(filename).mov").absoluteString)
        heicURL = URL(fileURLWithPath:directoryURL.appendingPathComponent("\(filename).heic").absoluteString)

        super.init(fileURL: directoryURL)
    }
    
    override func getImage() -> UIImage {
        return UIImage(contentsOfFile: imageURL.path)!
    }
    
    class func generateFolderForLivePhotoResources() -> URL? {
        let photoDir = NSURL(
            // NB: Files in NSTemporaryDirectory() are automatically cleaned up by the OS
            fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: true
            ).appendingPathComponent(NSUUID().uuidString)
        
        let fileManager = FileManager()
        // we need to specify type as ()? as otherwise the compiler generates a warning
        do {
            try fileManager.createDirectory(at: photoDir!,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            
            return photoDir!
        } catch {
            return nil
        }
    }
    
    class func SaveAssetResource(resource: PHAssetResource,
                                 inDirectory: URL,
                                 buffer: NSMutableData,
                                 maybeError: NSError?) -> Void {
        guard maybeError == nil else {
            print("Could not request data for resource: \(resource), error: \(String(describing: maybeError))")
            return
        }
        
        let maybeExt = UTTypeCopyPreferredTagWithClass(
            resource.uniformTypeIdentifier as CFString,
            kUTTagClassFilenameExtension
            )?.takeRetainedValue()
        
        guard let ext = maybeExt else {
            return
        }
        
        var fileUrl = inDirectory.appendingPathComponent(UUID().uuidString)
        fileUrl = fileUrl.appendingPathExtension(ext as String)
        
        if(!buffer.write(to: fileUrl, atomically: true)) {
            print("Could not save resource \(resource) to filepath \(fileUrl)")
        }
    }
}
