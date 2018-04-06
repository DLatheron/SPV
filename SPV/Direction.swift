//
//  Direction.swift
//  SPV
//
//  Created by dlatheron on 03/04/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//
import Foundation

enum Direction : Int, EnumCollection {
    case Ascending
    case Descending
    
    var localizedString: String {
        get {
            switch self {
            case .Ascending:
                return NSLocalizedString("⬆︎ Ascending",
                                         comment: "Ascending sort direction")
            case .Descending:
                return NSLocalizedString("⬇︎ Descending",
                                         comment: "Descending sort direction")
            }
        }
    }
}
