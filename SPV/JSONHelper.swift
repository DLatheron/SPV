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
    class func ToDate(string: String) -> Date? {
        return ISO8601DateFormatter().date(from: string)
    }
    
    class func ToString(date: Date?) -> String {
        return date == nil ? "null" : ISO8601DateFormatter().string(from: date!)
    }
    
    class func ToUUID(string : String) -> UUID? {
        return UUID(uuidString: string)
    }
    
    class func ToString(uuid: UUID?) -> String {
        return uuid == nil ? "null" : String(describing: uuid!)
    }
    
    class func StringArray(json: JSON, key: String) -> [String] {
        return json[key].arrayValue.map({$0.stringValue})
    }
    
    class func Load(fromURL fileURL: URL) throws -> String? {
        return try String(contentsOf: fileURL,
                          encoding: .utf8)
    }
    
    class func Save(toURL fileURL: URL,
                    jsonString: String) throws {
        try jsonString.write(to: fileURL,
                             atomically: false,
                             encoding: .utf8)
    }
    
    class func ToJSON(fromString jsonString: String) -> JSON? {
        if let dataFromString = jsonString.data(using: .utf8,
                                                allowLossyConversion: false) {
            return try? JSON(data: dataFromString,
                             options: .allowFragments)
        } else {
            return nil
        }
    }
}
