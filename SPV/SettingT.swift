//
//  SettingT.swift
//  SPV
//
//  Created by dlatheron on 15/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//
fileprivate let unspecifiedDefaultEditor = "TextCell"

class SettingT<T> : Setting {
    var name: String
    var value: T
    var editor: String = unspecifiedDefaultEditor
    
    init(name: String,
         value: T,
         editor: String? = nil) {
        self.name = name
        self.value = value
        self.editor = SettingT.chooseEditor(value: value,
                                            defaultEditor: editor)
    }
    
    static func chooseEditor(value: T, defaultEditor: String?) -> String {
        if defaultEditor == nil {
            switch value {
            case is Bool:
                return "BoolCell"
            case is String:
                return "TextCell"
            default:
                return unspecifiedDefaultEditor
            }
        }
        
        return defaultEditor ?? unspecifiedDefaultEditor
    }
}
