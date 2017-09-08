//
//  MediaManager
//  SPV
//
//  Created by dlatheron on 07/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class MediaManager {
    static var shared: MediaManager = MediaManager()
    
    let extensions = [
        "jpg",
        "jpeg",
        "png",
        "bmp",
        "gif"
    ]

    var media: [Media] = []
    
    init() {
    }
    
    func scanForMedia(atPath basePath: URL) {
        let filenames = extractAllFiles(atPath: basePath.absoluteString,
                                        withExtensions: extensions)
        for filename in filenames {
            let fileURL = basePath.appendingPathComponent(filename)
            let index = addMedia(url: fileURL)
            let media = getMedia(at: index)
            
            if !media.infoExists() {
                // Create a new media object and save it.
            }
        }
    }
    
    func addMedia(url fileURL: URL) -> Int {
        let newMedia = Media(fileURL: fileURL)
        
        media.append(newMedia)
        
        // TODO: Create the info file (if not already created, but at least ensure that it is up to date.
        // TODO: Separate function...
        let _ = getOrCreateMediaInfo(for: newMedia)

        
        return count - 1
    }
    
    internal func getOrCreateMediaInfo(for media: Media) -> MediaInfo {
        // TODO: On the media class???
        let mediaInfo : MediaInfo;
        
        do {
            mediaInfo = try MediaInfo.load(fromURL: media.infoURL)!
        } catch {
            mediaInfo = MediaInfo()
            mediaInfo.fileSize = 1234
            
            // TODO: More stuff...
            
            do {
                try mediaInfo.save(toURL: media.infoURL)
            } catch {
                // Not sure what to do here.
            }
        }
        
        return mediaInfo
    }
    
    func getMedia(at index: Int) -> Media {
        return media[index]
    }
    
    func getImage(at index: Int) -> UIImage? {
        return UIImage(contentsOfFile: getMedia(at: index).fileURL.absoluteString)
    }
    
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
