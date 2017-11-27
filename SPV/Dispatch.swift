//
//  Dispatch.swift
//  SPV
//
//  Created by dlatheron on 27/11/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class Dispatch {
    static func delay(callOf funcToCall: @escaping () -> Void,
                      for seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds,
                                      execute: {
            funcToCall()
        })
    }
}
