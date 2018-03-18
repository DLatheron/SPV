//
//  Settings.swift
//  SPV
//
//  Created by dlatheron on 15/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import SwiftyJSON

class SettingsBlock {
    var name: String
    var settings: [Setting]
    
    init(_ settings: [Setting],
         name: String? = nil) {
        self.name = name ?? ""
        self.settings = settings
    }
}

class Settings {
    static var shared: Settings = Settings()
    
    
    let httpServer = SettingT<String>(name: "Start HTTP Server", value: "HTTPServer", editor: "ButtonCell")
    let testOne = SettingT<Bool>(name: "Test One", value: true)
    let testTwo = SettingT<Bool>(name: "Test Two", value: false)
    let testName = SettingT<String>(name: "Test Name", value: "Nothing")
    let testConstData0 = SettingT<Any>(name: "Const Data #0", value: "Const Data", editor: "ConstDataCell")
    let testConstData1 = SettingT<Any>(name: "Const Data #1", value: 12, editor: "ConstDataCell")
    let setPIN = SettingT<String>(name: "Set PIN", value: "SetPIN", editor: "ButtonCell")
    let clearPIN = SettingT<String>(name: "Clear PIN", value: "ClearPIN", editor: "ButtonCell")

    let textLegalBlurb = SettingT<String>(name: "Legal Blurb", value:
"""
This is some legal gumpf.

It occupies quite a few lines of space.

But still appears correctly - even if there are really long lines of text
""", editor: "TextBlockCell")
    let pin = SettingT<String>(name: "PIN", value: "", editor: nil)
    let blurInBackground = SettingT<Bool>(name: "Blur in Background", value: true)
    let quickRating = SettingT<Bool>(name: "Quick Rating", value: true)
    
    let settingsBlock: SettingsBlock
    let legalSettingsBlock: SettingsBlock
    
    let testLegalSubMenu: SettingsSubMenu
    
    init() {
        legalSettingsBlock = SettingsBlock([
            testTwo,
            textLegalBlurb
        ], name: "Legal")
        
        testLegalSubMenu = SettingsSubMenu(legalSettingsBlock)

        settingsBlock = SettingsBlock([
            httpServer,
            testOne,
            testName,
            testConstData0,
            testConstData1,
            testLegalSubMenu,
            setPIN,
            clearPIN,
            blurInBackground,
            quickRating
        ])
    }
    
    internal func readFrom(json: JSON) {
        // This will automatically merge in new default settings,
        // but cannot foricbly update existing settings (you have
        // to rename them).
        testOne.value = json["testOne"].bool ?? true
        testTwo.value = json["testTwo"].bool ?? false
        testName.value = json["testName"].string ?? ""
        testConstData0.value = json["testConstData0"].rawValue
        testConstData1.value = json["testConstData1"].rawValue
        pin.value = json["pin"].string ?? ""
        blurInBackground.value = json["blurInBackground"].bool ?? true
        quickRating.value = json["quickRating"].bool ?? true
    }
    
    internal func writeAsJSON() -> JSON {
        return JSON([
            "testOne": testOne.value,
            "testTwo": testTwo.value,
            "testName": testName.value,
            "testConstData0": testConstData0.value,
            "testConstData1": testConstData1.value,
            "pin": pin.value,
            "blurInBackground": blurInBackground.value,
            "quickRating": quickRating.value
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
