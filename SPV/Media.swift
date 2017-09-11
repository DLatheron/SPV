//
//  Media.swift
//  SPV
//
//  Created by dlatheron on 05/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
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
        return UIImage(contentsOfFile: fileURL.absoluteString)!
    }
    
    func saveInfo(info: MediaInfo) {
        do {
            try info.save(toURL: infoURL,
                          evenIfUnchanged: false)
        } catch {
            print("Failed to save media info because: \(error)")
        }
    }
    
    private class func makeInfoURL(fileURL: URL) -> URL {
        return URL(fileURLWithPath: fileURL.appendingPathExtension(Media.mediaInfoExtension).absoluteString)
    }
    
    private class func loadOrCreateMediaInfo(forFileURL fileURL: URL) -> MediaInfo {
        let infoURL = makeInfoURL(fileURL: fileURL)
        let mediaInfo : MediaInfo;
        
        do {
            mediaInfo = try MediaInfo.load(fromURL: infoURL)!
        } catch {
            mediaInfo = MediaInfo()
            do {
                let fileAttribute = try FileManager.default.attributesOfItem(atPath: fileURL.path)
                
                if let fileNumberSize: NSNumber = fileAttribute[FileAttributeKey.size] as? NSNumber {
                    mediaInfo.fileSize = UInt64(fileNumberSize)
                }
            } catch {
                print("Failed to get filesize because: \(error)")
                mediaInfo.fileSize = 0
            }
            mediaInfo.resolution.width = 123
            mediaInfo.resolution.height = 456
            
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
}
