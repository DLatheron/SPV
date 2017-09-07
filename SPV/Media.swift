//
//  Media.swift
//  SPV
//
//  Created by dlatheron on 05/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class Media {
    static var mediaInfoExtension = "info"
    
    var fileURL: URL
    
    var filename: String {
        get {
            return fileURL.lastPathComponent
        }
    }
    
    var infoURL: URL {
        get {
            return fileURL.appendingPathExtension(Media.mediaInfoExtension)
        }
    }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
    
    func loadInfo() -> MediaInfo? {
        do {
            return try MediaInfo.load(fromURL: infoURL)
        } catch {
            print("Failed to load media info because: \(error)")
            return nil
        }
    }
    
    func saveInfo(info: MediaInfo) {
        do {
            try info.save(toURL: infoURL)
        } catch {
            print("Failed to save media info because: \(error)")
        }
    }
}
