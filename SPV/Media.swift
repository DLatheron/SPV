//
//  Media.swift
//  SPV
//
//  Created by dlatheron on 05/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import ImageIO
import UIKit

class Media : NSObject {
    static var mediaInfoExtension = "info"
    
    private(set) var fileURL: URL
    private(set) var mediaInfo: MediaInfo
    
    var id: UUID {
        get {
            return mediaInfo.id
        }
    }
    
    var filename: String {
        get {
            return fileURL.lastPathComponent
        }
    }
    
    var infoURL: URL {
        get {
            return Media.makeInfoURL(fileURL: fileURL)
        }
    }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        self.mediaInfo = Media.loadOrCreateMediaInfo(forFileURL: fileURL)
    }
    
    func getImage() -> UIImage {
        return UIImage(contentsOfFile: fileURL.path)!
    }

    func saveInfo(info: MediaInfo) {
        do {
            try info.save(toURL: infoURL,
                          evenIfUnchanged: false)
        } catch {
            print("Failed to save media info because: \(error)")
        }
    }
    
    func deleteInfo(_ info: MediaInfo) {
        do {
            try FileManager.default.removeItem(at: infoURL)
        } catch {
            print("Failed to delete media info because: \(error)")
        }
    }
    
    func save() {
        saveInfo(info: mediaInfo)
    }
    
    func deleteMedia() {
        do {
            try FileManager.default.removeItem(at: URL(fileURLWithPath:fileURL.absoluteString))
        } catch {
            print("Failed to delete media because: \(error)")
        }
    }
    
    func delete() {
        deleteInfo(mediaInfo)
        deleteMedia()
    }
    
    private class func makeInfoURL(fileURL: URL) -> URL {
        return URL(fileURLWithPath: fileURL.absoluteString).appendingPathExtension(Media.mediaInfoExtension) // TODO Recently changed...
    }
    
    private class func loadOrCreateMediaInfo(forFileURL fileURL: URL) -> MediaInfo {
        let infoURL = makeInfoURL(fileURL: fileURL)
        let mediaInfo : MediaInfo
        
        do {
            mediaInfo = try MediaInfo.load(fromURL: infoURL)!
        } catch {
            mediaInfo = MediaInfo()
            do {
                let fileAttribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                
                if let fileNumberSize: NSNumber = fileAttribute[FileAttributeKey.size] as? NSNumber {
                    mediaInfo.fileSize = Int64(truncating: fileNumberSize)
                }
            } catch {
                print("Failed to get filesize because: \(error)")
                mediaInfo.fileSize = 0
            }
            
            if let image = UIImage(contentsOfFile: fileURL.path) {
                mediaInfo.resolution.width = Int(image.size.width)
                mediaInfo.resolution.height = Int(image.size.height)
            }
            
            if let creationDate = fileCreationDate(for: fileURL) {
                mediaInfo.creationDate = creationDate
            }
            
//            if let size = sizeForImage(at: fileURL) {
//                mediaInfo.resolution.width = Int(size.width)
//                mediaInfo.resolution.height = Int(size.height)
//            }
            
            do {
                try mediaInfo.save(toURL: infoURL,
                                   evenIfUnchanged: true)
            } catch {
                // Not sure what to do here.
                print("Failed to save info file because: \(error)")
            }
        }
        
        return mediaInfo
    }
    
    private class func fileCreationDate(for url: URL) -> Date? {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.absoluteString) as NSDictionary
            return attrs.fileCreationDate()
        } catch {
            return nil
        }
    }
    
//    private class func sizeForImage(at url: URL) -> CGSize? {
//        guard let imageSource = CGImageSourceCreateWithURL(url as CFURL, nil)
//            , let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as? [AnyHashable: Any]
//            , let pixelWidth = imageProperties[kCGImagePropertyPixelWidth as String]
//            , let pixelHeight = imageProperties[kCGImagePropertyPixelHeight as String]
//            , let orientationNumber = imageProperties[kCGImagePropertyOrientation as String]
//            else {
//                return nil
//        }
//        
//        var width: CGFloat = 0
//        var height: CGFloat = 0
//        var orientation: Int = 0
//        
//        CFNumberGetValue(pixelWidth as! CFNumber, .cgFloatType, &width)
//        CFNumberGetValue(pixelHeight as! CFNumber, .cgFloatType, &height)
//        CFNumberGetValue(orientationNumber as! CFNumber, .intType, &orientation)
//        
//        // Check orientation and flip size if required
//        if orientation > 4 { let temp = width; width = height; height = temp }
//        
//        return CGSize(width: width, height: height)
//    }
}
