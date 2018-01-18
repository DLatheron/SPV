//
//  MediaExtensionTest.swift
//  SPVTests
//
//  Created by dlatheron on 18/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import XCTest
@testable import SPV

class MediaExtensionTest : XCTestCase {
    
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
    
    
    func test_fileExtensions() {
        let fileExtensions = MediaExtension.fileExtensions
        
        XCTAssertEqual(fileExtensions, [".jpg",".jpeg", ".png", ".bmp", ".gif", ".mov", ".mp4"]);
    }
    
    func test_extensions() {
        let extensions = MediaExtension.extensions
        
        XCTAssertEqual(extensions, ["jpg", "jpeg", "png", "bmp", "gif", "mov", "mp4"]);
    }
    
    func test_getFileExtension() {
        XCTAssertEqual(MediaExtension.getFileExtension(.jpg), ".jpg")
        XCTAssertEqual(MediaExtension.getFileExtension(.mov), ".mov")
        XCTAssertEqual(MediaExtension.getFileExtension(.bmp), ".bmp")
    }
    
    func test_getExtension() {
        XCTAssertEqual(MediaExtension.getExtension(.jpeg), "jpeg")
        XCTAssertEqual(MediaExtension.getExtension(.png), "png")
        XCTAssertEqual(MediaExtension.getExtension(.mov), "mov")
    }
    
    func test_isValidExtension() {
        XCTAssertEqual(MediaExtension.isValidExtension(".jpeg"), true)
        XCTAssertEqual(MediaExtension.isValidExtension(".MOV"), true)
        XCTAssertEqual(MediaExtension.isValidExtension(".Mp4"), true)

        XCTAssertEqual(MediaExtension.isValidExtension(".jpog"), false)
        XCTAssertEqual(MediaExtension.isValidExtension(".MP3"), false)
        XCTAssertEqual(MediaExtension.isValidExtension(".PoNG"), false)
    }
}
