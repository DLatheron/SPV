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
        return ISO8601DateFormatter().date(from: isoString)
    }
    
    class func StringArray(json: JSON, key: String) -> [String] {
        return json[key].arrayValue.map({$0.stringValue})
    }
}
