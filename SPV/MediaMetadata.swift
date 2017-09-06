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
    var tags: [String] = []
    
    
    init() {
    }
    
    init?(jsonString: String) {
        if let dataFromString = jsonString.data(using: .utf8,
                                                allowLossyConversion: false) {
            let json = JSON(data: dataFromString,
                            options: .allowFragments)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            
            self.rating = json["rating"].intValue
            self.dateDownloaded = dateFormatter.date(from: json["downloaded"].stringValue)
            self.tags = json["tags"].arrayValue.map({$0.stringValue})
        } else {
            return nil
        }
    }
}
