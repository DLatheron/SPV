//
//  MediaInfo.swift
//  SPV
//
//  Created by dlatheron on 05/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class MediaInfo {
    struct MediaSize : Equatable {
        var width: Int {
            didSet {
                if width != oldValue {
                    modified = true
                }
            }
        }
        var height: Int {
            didSet {
                if height != oldValue {
                    modified = true
                }
            }
        }
        
        private(set) var modified: Bool

        init() {
            width = 0
            height = 0
            modified = false
        }
        
        init(width: Int, height: Int) {
            self.width = width
            self.height = height
            self.modified = false
        }
        
        static func == (lhs: MediaSize, rhs: MediaSize) -> Bool {
            return lhs.width == rhs.width && lhs.height == rhs.height
        }
    }
    
    
    // JSON.
    var id: UUID {
        didSet {
            if id != oldValue {
                modified = true
            }
        }
    }
    
    var title: String {
        didSet {
            if title != oldValue {
                modified = true
            }
        }
    }
    
    var source: String {
        didSet {
            if source != oldValue {
                modified = true
            }
        }
    }
    
    var importDate: Date {
        didSet {
            if importDate != oldValue {
                modified = true
            }
        }
    }
    
    var creationDate: Date {
        didSet {
            if creationDate != oldValue {
                modified = true
            }
        }
    }
    
    var fileSize: Int64 {
        didSet {
            if fileSize != oldValue {
                modified = true
            }
        }
    }
    
    var resolution: MediaSize = MediaSize() {
        didSet {
            if resolution != oldValue {
                modified = true
            }
        }
    }
    
    var previousViews: Int {
        didSet {
            if previousViews != oldValue {
                modified = true
            }
        }
    }
    
    var lastViewed: Date? {
        didSet {
            if lastViewed != oldValue {
                modified = true
            }
        }
    }
    
    var rating: Int {
        didSet {
            if rating != oldValue {
                modified = true
            }
        }
    }
    
    var dateDownloaded: Date {
        didSet {
            if dateDownloaded != oldValue {
                modified = true
            }
        }
    }
    
    var tags: [String] {
        didSet {
            if tags != oldValue {
                modified = true
            }
        }
    }
    
    private(set) var modified: Bool = false
    var hasChanged: Bool {
        get {
            return modified || resolution.modified;
        }
    }
    
    
    init() {
        self.id = UUID()
        self.title = ""
        self.source = ""
        self.importDate = Date()
        self.creationDate = Date()
        self.fileSize = 0
        self.resolution = MediaSize()
        self.previousViews = 0
        self.lastViewed = Date()
        self.rating = 3
        self.dateDownloaded = Date()
        self.tags = []
        
        self.modified = false
    }
    
    init?(jsonString: String) {
        if let json = JSONHelper.ToJSON(fromString: jsonString) {
            self.id = JSONHelper.ToUUID(string: json["id"].stringValue)!
            self.title = json["title"].stringValue
            self.source = json["source"].stringValue
            self.importDate = JSONHelper.ToDate(string: json["importDate"].stringValue)!
            self.creationDate = JSONHelper.ToDate(string: json["creationDate"].stringValue)!
            self.fileSize = json["fileSize"].int64Value
            self.resolution.width = json["resolution"]["width"].intValue
            self.resolution.height = json["resolution"]["height"].intValue
            self.previousViews = json["previousViews"].intValue
            self.lastViewed = JSONHelper.ToDate(string: json["lastViewed"].stringValue)
            self.rating = json["rating"].intValue
            self.dateDownloaded = JSONHelper.ToDate(string: json["dateDownloaded"].stringValue)!
            self.tags = JSONHelper.StringArray(json: json, key:"tags")
            
            self.modified = false
        } else {
            return nil
        }
    }
    
    internal func makeJSON() -> JSON {
        return JSON([
            "title": title,
            "id": JSONHelper.ToString(uuid: id),
            "source": source,
            "importDate": JSONHelper.ToString(date: importDate),
            "creationDate": JSONHelper.ToString(date: creationDate),
            "fileSize": fileSize,
            "resolution": [
                "width": resolution.width,
                "height": resolution.height],
            "previousViews": previousViews,
            "lastViewed": JSONHelper.ToString(date: lastViewed),
            "rating": rating,
            "tags": tags
        ])
    }
    
    internal func makeJSONString() -> String {
        return makeJSON().rawString() ?? "{}"
    }
    
    class func load(fromURL fileURL: URL) throws -> MediaInfo? {
        if let jsonString = try JSONHelper.Load(fromURL: fileURL) {
            return MediaInfo(jsonString: jsonString)
        } else {
            return nil
        }
    }
    
    func save(toURL fileURL: URL) throws {
        try JSONHelper.Save(toURL: fileURL,
                            jsonString: makeJSONString())
        modified = false
    }
}
