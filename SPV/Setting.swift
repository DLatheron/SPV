//
//  Setting.swift
//  SPV
//
//  Created by dlatheron on 13/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol Setting {
    var name: String { get }
    var cellId: String { get }
}

class SettingT<T> : Setting {
    var name: String
    var value: T
    
    var cellId: String {
        get {
            return "BoolCell"
        }
    }
    
    
    init(name: String,
         value: T) {
        self.name = name
        self.value = value
    }
}

class Settings {
    static var shared: Settings = Settings()

    
    let testOne = SettingT<Bool>(name: "Test One", value: true)
    let testTwo = SettingT<Bool>(name: "Test Two", value: false)
    
    var settings: [Setting] {
        get {
            return [
                testOne,
                testTwo
            ]
        }
    }
    
    internal func readFrom(json: JSON) {
        // This will automatically merge in new default settings,
        // but cannot foricbly update existing settings (you have
        // to rename them).
        testOne.value = json["testOne"].boolValue
        testTwo.value = json["testTwo"].boolValue
    }
    
    internal func writeAsJSON() -> JSON {
        return JSON([
            "testOne": testOne.value,
            "testTwo": testTwo.value
        ])
    }
    
    internal func writeAsJSONString() -> String {
        return writeAsJSON().rawString() ?? "{}"
    }
    
    func load(fromFileURL fileURL: URL) throws {
        if let jsonString = try JSONHelper.Load(fromURL: fileURL) {
            if let json = JSONHelper.ToJSON(fromString: jsonString) {
                readFrom(json: json)
            }
        }
    }
    
    func save(toFileURL fileURL: URL) throws {
        try JSONHelper.Save(toURL: fileURL,
                            jsonString: writeAsJSONString())
    }
    
    static var defaultURL: URL {
        get {
            let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let settingsURL = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("settings.json")

            return settingsURL
        }
    }
}
