//
//  MediaMetadata.swift
//  SPV
//
//  Created by dlatheron on 05/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import SwiftyJSON

class MediaMetadata {
    var rating: Int = 0
    var dateDownloaded: Date? = Date()
    
    
    init() {
    }
    
    init?(jsonString: String) {
        if let dataFromString = jsonString.data(using: .utf8,
                                                allowLossyConversion: false) {
            let json = JSON(data: dataFromString)
            let mediaMetadata = json["MediaMetadata"]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            
            self.rating = mediaMetadata["Rating"].intValue
            self.dateDownloaded = dateFormatter.date(from: mediaMetadata["Downloaded"].stringValue)
        } else {
            return nil
        }
    }
}
