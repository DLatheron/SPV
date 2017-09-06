//
//  JsonHelper.swift
//  SPV
//
//  Created by dlatheron on 06/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import SwiftyJSON

class JSONHelper {
    class func ISOStringToDate(_ isoString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return dateFormatter.date(from: isoString)
    }
    
    class func StringArray(json: JSON, key: String) -> [String] {
        return json[key].arrayValue.map({$0.stringValue})
    }
}
