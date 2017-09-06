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
        if let dataFromString = jsonString.data(using: .utf8,
                                                allowLossyConversion: false) {
            let json = JSON(data: dataFromString,
                            options: .allowFragments)
            
            self.title = json["title"].stringValue
            self.id = UUID(uuidString: json["id"].stringValue)
            self.source = json["source"].stringValue
            self.importDate = JSONHelper.ISOStringToDate(json["importDate"].stringValue)
            self.creationDate = JSONHelper.ISOStringToDate(json["creationDate"].stringValue)
            self.fileSize = json["fileSize"].int64Value
            self.resolution.width = json["resolution"]["width"].intValue
            self.resolution.height = json["resolution"]["height"].intValue
            self.previousViews = json["previousViews"].intValue
            self.lastViewed = JSONHelper.ISOStringToDate(json["lastViewed"].stringValue)
            self.rating = json["rating"].intValue
            self.tags = JSONHelper.StringArray(json: json, key:"tags")
        } else {
            return nil
        }
    }
}
