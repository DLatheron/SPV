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
    struct MediaSize {
        var width: Int = 0
        var height: Int = 0
    }
    
    
    var title: String = ""
    var id: UUID? = nil
    var source: String = ""
    var importDate: Date? = nil
    var creationDate: Date? = nil
    var fileSize: Int64 = 0
    var resolution: MediaSize = MediaSize()
    var previousViews: Int = 0
    var lastViewed: Date? = nil
    var rating: Int = 0
    var dateDownloaded: Date? = Date()
    var tags: [String] = []
    
    
    init() {
    }
    
    init?(jsonString: String) {
        if let json = JSONHelper.ToJSON(fromString: jsonString) {
            self.title = json["title"].stringValue
            self.id = JSONHelper.ToUUID(string: json["id"].stringValue)
            self.source = json["source"].stringValue
            self.importDate = JSONHelper.ToDate(string: json["importDate"].stringValue)
            self.creationDate = JSONHelper.ToDate(string: json["creationDate"].stringValue)
            self.fileSize = json["fileSize"].int64Value
            self.resolution.width = json["resolution"]["width"].intValue
            self.resolution.height = json["resolution"]["height"].intValue
            self.previousViews = json["previousViews"].intValue
            self.lastViewed = JSONHelper.ToDate(string: json["lastViewed"].stringValue)
            self.rating = json["rating"].intValue
            self.tags = JSONHelper.StringArray(json: json, key:"tags")
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
    
    class func load(fileURL: URL) throws -> MediaInfo? {
        if let jsonString = try JSONHelper.Load(fromURL: fileURL) {
            return MediaInfo(jsonString: jsonString)
        } else {
            return nil
        }
    }
    
    func save(fileURL: URL) throws {
        try JSONHelper.Save(toURL: fileURL,
                            jsonString: makeJSONString())
    }
}
