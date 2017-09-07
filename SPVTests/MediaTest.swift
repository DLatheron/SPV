//
//  MediaTest.swift
//  SPV
//
//  Created by dlatheron on 07/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import XCTest
@testable import SPV

class MediaTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init() {
        
    }
    
    func test_infoURL() {
        let fileURL = URL(fileURLWithPath: "./image001.jpg")
        let media = Media(fileURL: fileURL)
        
        XCTAssertEqual(media.infoURL, URL(fileURLWithPath: "./image001.jpg.info"));
    }
}
