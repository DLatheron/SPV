//
//  URLExtension.swift
//  SPV
//
//  Created by dlatheron on 23/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation

extension URL {
    func ensureFileURL() -> URL {
        if isFileURL {
            return self
        } else {
            return URL(fileURLWithPath: absoluteString)
        }
    }
}

