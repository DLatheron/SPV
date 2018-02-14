//
//  MediaExtension.swift
//  SPV
//
//  Created by dlatheron on 18/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation

enum MediaType {
    case photo
    case video
    case livePhoto
}

enum MediaExtension : String, EnumCollection {
    case jpg
    case png
    case bmp
    case gif
    case mov
    case mp4
    case livePhoto
    
    var type: MediaType {
        get {
            return MediaExtension.getType(self)
        }
    }
    
    var isPhoto: Bool {
        get {
            return type == MediaType.photo
        }
    }
    
    var isVideo: Bool {
        get {
            return type == MediaType.video
        }
    }
    
    var extensions: [String] {
        get {
            return MediaExtension.getExtensions(self)
        }
    }
    
    var fileExtensions: [String] {
        get {
            return MediaExtension.getFileExtensions(self)
        }
    }
    
    var ext: String {
        get {
            return extensions[0]
        }
    }
    
    var fileExt: String {
        get {
            return fileExtensions[0]
        }
    }
    
    static var allFileExtensions: [String] {
        get {
            return allValues.flatMap({ getFileExtensions($0) })
        }
    }
    
    static var allExtensions: [String] {
        get {
            return allValues.flatMap({ getExtensions($0) })
        }
    }
    
    static func getType(_ ext: MediaExtension) -> MediaType {
        switch ext {
        case jpg: return MediaType.photo
        case png: return MediaType.photo
        case bmp: return MediaType.photo
        case gif: return MediaType.photo
        case mov: return MediaType.video
        case mp4: return MediaType.video
        case livePhoto: return MediaType.livePhoto
        }
    }
    
    static func getFileExtensions(_ ext: MediaExtension) -> [String] {
        return getExtensions(ext).map({ ".\($0)" })
    }
    
    static func getExtensions(_ ext: MediaExtension) -> [String] {
        switch ext {
        case .jpg: return ["jpg", "jpeg"]
        case .png: return ["png"]
        case .bmp: return ["bmp"]
        case .gif: return ["gif"]
        case .mov: return ["mov"]
        case .mp4: return ["mp4"]
        case .livePhoto: return ["livephoto"]
        }
    }
    
    static func isValidExtension(_ extString: String) -> Bool {
        return fromExtension(extString) != nil
    }
    
    static func fromExtension(_ extString: String) -> MediaExtension? {
        let lowercase = extString.lowercased()
        
        for mediaExt in MediaExtension.allValues {
            let extensions = MediaExtension.getFileExtensions(mediaExt)
            for ext in extensions {
                if lowercase.hasSuffix(ext) {
                    return mediaExt
                }
            }
        }
        
        return nil
    }
}
