//
//  MediaManager
//  SPV
//
//  Created by dlatheron on 07/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

protocol MediaManagerChangedProtocol: class {
    func added(media: Media)
    func changed(media: Media)
    func deleted(media: Media)
}

class MediaManager {
    static var shared: MediaManager = MediaManager()
    
    weak var delegate: MediaManagerChangedProtocol?

    var media: [Media] = []
    
    var idToMedia: [UUID: Media] = [:]
    
    init() {
    }
    
    func scanForMedia(atPath basePath: URL) {
        let filenames = extractAllFiles(atPath: basePath.absoluteString,
                                        withExtensions: MediaExtension.allExtensions)
        for filename in filenames {
            let fileURL = basePath.appendingPathComponent(filename)
            _ = addMedia(url: fileURL)
        }
        
        //try? saveIfNecessary()
    }
    
    func addMedia(url fileURL: URL) -> Media {
        let newMedia: Media
        
        switch (fileURL.pathExtension.lowercased()) {
        case "gif":
            newMedia = PhotoGIF(fileURL: fileURL)
        case "mov":
            newMedia = Video(fileURL: fileURL)
        case "mp4":
            newMedia = Video(fileURL: fileURL)
        case "livephoto":
            newMedia = LivePhoto(directoryURL: fileURL)
        default:
            newMedia = Photo(fileURL: fileURL)
        }
        
        media.append(newMedia)
        idToMedia[newMedia.id] = newMedia
        
        delegate?.added(media: newMedia)
        
        return newMedia
    }
    
    func deleteMedia(_ mediaToDelete: Media) {
        print("Deleting: \(mediaToDelete.id)")
        delegate?.deleted(media: mediaToDelete)

        if let index = media.index(of: mediaToDelete) {
            media.remove(at: index)
        }

        mediaToDelete.delete()
    }
    
    func moveMedia(_ id: UUID,
                   toFolder: String) {
    }
    
    func shareMedia(_ id: UUID) {
    }
    
    class func GetNextFilename(basePath: URL,
                               filenamePrefix: String,
                               numberOfDigits: Int = 6,
                               filenamePostfix: String) -> URL? {
        // TODO: Precache the filename list rather than checking against the filesystem?
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = numberOfDigits
        
        let maximumNumber = numberOfDigits * 10
        
        for number in 0..<maximumNumber {
            let formattedNumber = formatter.string(from: NSNumber(value: number))!
            let filename = "\(filenamePrefix)\(formattedNumber)\(filenamePostfix)"
            let fileURL = basePath.appendingPathComponent(filename)
            
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                return fileURL
            }
        }
        
        return nil
    }
    
    class var DocumentsDirectoryURL: URL {
        get {
            let paths = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask)
            return paths[0] as URL
        }
    }
    
    class func GetNextFileURL(filenamePrefix: String,
                              numberOfDigits: Int = 6,
                              filenamePostfix: String) -> URL? {
        return GetNextFilename(basePath: DocumentsDirectoryURL,
                               filenamePrefix: filenamePrefix,
                               numberOfDigits: numberOfDigits,
                               filenamePostfix: filenamePostfix)
    }
    
    func getMedia(byId id: UUID) -> Media {
        return idToMedia[id]!
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
        if let files = try? fileManager.contentsOfDirectory(atPath: pathString) {
            for (_, file) in files.enumerated() {
                if let path = NSURL(fileURLWithPath: file,
                                    relativeTo: pathURL as URL).path {
                    let fileExt = (path as NSString).pathExtension
                    
                    // TODO: Case insensitive.
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

extension MediaManager {
    class func MakeLocalFileURL(filename: String) -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                     .userDomainMask,
                                                                     true)[0]
        let documentsURL = URL(string: documentsDirectory)!
        let fullURL = documentsURL.appendingPathComponent(filename)
    
        return URL(fileURLWithPath: fullURL.absoluteString)
    }
}

extension MediaManager {
    internal func fileModificationDate(url: URL) -> Date? {
        do {
            let attr = try FileManager.default.attributesOfItem(atPath: url.path)
            return attr[FileAttributeKey.modificationDate] as? Date
        } catch {
            return nil
        }
    }
    
    internal func toJSON(media: Media) -> JSON {
        let lastModificationDate = fileModificationDate(url: media.fileURL)
        
        return JSON([
            "filename": media.filename,
            "extension": media.mediaExtension.ext,
            "date": JSONHelper.ToString(date: lastModificationDate)
        ])
    }
    
    internal func toJSON() -> JSON {
        var json = JSON()
        
        json["media"] = JSON(media.map({ (entry) in
            return toJSON(media: entry)
        }))
        
        return json
    }
    
    internal func mediaFromJSON(_ json: JSON) -> Media {
        let filename = json["filename"].stringValue
        // TODO: Do something with the extension and date???
        //let ext = json["extension"].stringValue
        //let date = JSONHelper.ToDate(string: json["date"].stringValue)

        // Is there any point to this given that reading it from JSON is probably slower than reading the directory layout from disk???
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(string: documentsDirectory)!
        let fileURL = documentsURL.appendingPathComponent(filename)
        
        return Media(fileURL: fileURL)
    }
    
    internal func fromJSON(_ json: JSON) throws {
        let jsonMediaArray = json["media"].arrayValue
        var media: [Media] = []
        
        for (_, entry) in jsonMediaArray.enumerated() {
            let newMedia = mediaFromJSON(entry)
            media.append(newMedia)
        }
    }
    
    var dbFilePath: URL {
        get {
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let documentsURL = URL(string: documentsDirectory)!
            let dbFilePath = documentsURL.appendingPathComponent(".MediaManager.json")

            return URL(fileURLWithPath: dbFilePath.absoluteString)
        }
    }
    
    func saveIfNecessary() throws {
        if true {
            try saveTo(fileURL: dbFilePath)
        }
    }
    
    func saveTo(fileURL: URL) throws {
        let json = toJSON()
        
        do {
            try JSONHelper.Save(toURL: fileURL,
                                jsonString: json.rawString() ?? "{}")
        } catch {
            print("Failed to save Media Manager database because:", error.localizedDescription)
        }
    }
    
    func loadFrom(fileURL: URL) throws {
        do {
            let jsonString = try JSONHelper.Load(fromURL: fileURL)!
            let json = JSONHelper.ToJSON(fromString: jsonString)!
            try fromJSON(json)
        } catch {
            print("Failed to load Media Manager database because:", error.localizedDescription)
        }
    }
}
