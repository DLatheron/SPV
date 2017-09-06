//
//  JsonTestHelper.swift
//  SPV
//
//  Created by dlatheron on 06/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class JSONTestHelper {
    class func BuildJSON(_ lines: [String]) -> String {
        return lines.joined(separator: "")
            .replacingOccurrences(of: "'",
                                  with: "\"");
    }
}
