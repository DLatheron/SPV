//
//  MediaManager
//  SPV
//
//  Created by dlatheron on 07/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol MediaManagerChangedProtocol: class {
    func added(media: Media)
    func changed(media: Media)
    func deleted(media: Media)
}

class MediaManager {
    static var shared: MediaManager = MediaManager()
    
    weak var delegate: MediaManagerChangedProtocol?
    
    let extensions = [
        "jpg",
        "jpeg",
        "png",
        "bmp",
        "gif"
    ]

    var media: [Media] = []
    
    var idToMedia: [UUID: Media] = [:]
    
    init() {
    }
    
    func scanForMedia(atPath basePath: URL) {
        let filenames = extractAllFiles(atPath: basePath.absoluteString,
                                        withExtensions: extensions)
        for filename in filenames {
            let fileURL = basePath.appendingPathComponent(filename)
            _ = addMedia(url: fileURL)
        }
    }
    
    func addMedia(url fileURL: URL) -> Media {
        let newMedia = Media(fileURL: fileURL)
        
        media.append(newMedia)
        idToMedia[newMedia.id] = newMedia
        
        delegate?.added(media: newMedia)
        
        return newMedia
    }
    
    func getNextFilename(basePath: String,
                         filenamePrefix: String,
                         numberOfDigits: Int = 6,
                         filenamePostfix: String) -> String? {
        // TODO: Precache the filename list rather than checking against the filesystem?
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = numberOfDigits
        
        let maximumNumber = numberOfDigits * 10
        
        for number in 0..<maximumNumber {
            let formattedNumber = formatter.string(from: NSNumber(value: number))!
            let filename = "\(filenamePrefix)\(formattedNumber)\(filenamePostfix)"
            let path = (basePath as NSString).appendingPathComponent(filename)
            
            if !FileManager.default.fileExists(atPath: path) {
                return path
            }
        }
        
        return nil
    }
    
//    func getMedia(at index: Int) -> Media {
//        return media[index]
//    }
    
    func getMedia(byId id: UUID) -> Media {
        return idToMedia[id]!
    }
    
//    func getImage(at index: Int) -> UIImage? {
//        return UIImage(contentsOfFile: getMedia(at: index).fileURL.absoluteString)
//    }
    
//    func getImage(byId id: UUID) -> UIImage? {
//        return UIImage(contentsOfFile: getMedia(byId: id).fileURL.absoluteString)
//    }
    
    public var count: Int {
        get {
            return media.count
        }
    }
    
    // Based on: https://stackoverflow.com/a/41979088/1176581
    private func extractAllFiles(atPath path: String,
                                 withExtensions fileExtensions: [String]) -> [String] {
        let pathURL = NSURL(fileURLWithPath: path,
                            isDirectory: true)
        var allFiles: [String] = []
        let fileManager = FileManager.default
        let pathString = path.replacingOccurrences(of: "file:", with: "")
        if let enumerator = fileManager.enumerator(atPath: pathString) {
            for file in enumerator {
                if let path = NSURL(fileURLWithPath: file as! String,
                                    relativeTo: pathURL as URL).path {
                    let fileExt = (path as NSString).pathExtension
                    
                    if fileExtensions.contains(fileExt) {
                        let filename = (path as NSString).lastPathComponent
                        allFiles.append(filename)
                    }
                }
            }
        }
        return allFiles
    }
}
