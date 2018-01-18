//
//  MediaExtension.swift
//  SPV
//
//  Created by dlatheron on 18/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation

enum MediaExtension : String, EnumCollection {
    case jpg
    case jpeg
    case png
    case bmp
    case gif
    case mov
    case mp4
    
    static var fileExtensions: [String] {
        get {
            return allValues.map({ getFileExtension($0) })
        }
    }
    
    static var extensions: [String] {
        get {
            return allValues.map({ getExtension($0) })
        }
    }
    
    static func getFileExtension(_ ext: MediaExtension) -> String {
        return ".\(getExtension(ext))"
    }
    
    static func getExtension(_ ext: MediaExtension) -> String {
        switch ext {
        case .jpg: return "jpg"
        case .jpeg: return "jpeg"
        case .png: return "png"
        case .bmp: return "bmp"
        case .gif: return "gif"
        case .mov: return "mov"
        case .mp4: return "mp4"
        }
    }
    
    static func isValidExtension(_ extString: String) -> Bool {
        return fromExtension(extString) != nil
    }
    
    static func fromExtension(_ extString: String) -> MediaExtension? {
        let lowercase = extString.lowercased()
        
        for mediaExt in MediaExtension.allValues {
            let ext = MediaExtension.getFileExtension(mediaExt)
            if lowercase.hasSuffix(ext) {
                return mediaExt
            }
        }
        
        return nil
    }
}
