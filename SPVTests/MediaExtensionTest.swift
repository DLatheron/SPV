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
    
    func test_allFileExtensions() {
        let fileExtensions = MediaExtension.allFileExtensions
        
        XCTAssertEqual(fileExtensions, [".jpg",".jpeg", ".png", ".bmp", ".gif", ".mov", ".mp4"]);
    }
    
    func test_allExtensions() {
        let extensions = MediaExtension.allExtensions
        
        XCTAssertEqual(extensions, ["jpg", "jpeg", "png", "bmp", "gif", "mov", "mp4"]);
    }
    
    func test_getFileExtension() {
        XCTAssertEqual(MediaExtension.getFileExtensions(.jpg), [".jpg", ".jpeg"])
        XCTAssertEqual(MediaExtension.getFileExtensions(.mov), [".mov"])
        XCTAssertEqual(MediaExtension.getFileExtensions(.bmp), [".bmp"])
    }
    
    func test_getExtension() {
        XCTAssertEqual(MediaExtension.getExtensions(.jpg), ["jpg", "jpeg"])
        XCTAssertEqual(MediaExtension.getExtensions(.png), ["png"])
        XCTAssertEqual(MediaExtension.getExtensions(.mov), ["mov"])
    }
    
    func test_isValidExtension() {
        XCTAssertEqual(MediaExtension.isValidExtension(".jpeg"), true)
        XCTAssertEqual(MediaExtension.isValidExtension(".MOV"), true)
        XCTAssertEqual(MediaExtension.isValidExtension(".Mp4"), true)

        XCTAssertEqual(MediaExtension.isValidExtension(".jpog"), false)
        XCTAssertEqual(MediaExtension.isValidExtension(".MP3"), false)
        XCTAssertEqual(MediaExtension.isValidExtension(".PoNG"), false)
    }
    
    func test_fromExtension() {
        XCTAssertEqual(MediaExtension.fromExtension(".jpeg"), MediaExtension.jpg)
        XCTAssertEqual(MediaExtension.fromExtension(".png"), MediaExtension.png)
        XCTAssertEqual(MediaExtension.fromExtension(".mov"), MediaExtension.mov)
        
        XCTAssertEqual(MediaExtension.fromExtension(".txt"), nil)
        XCTAssertEqual(MediaExtension.fromExtension(".pdf"), nil)
        XCTAssertEqual(MediaExtension.fromExtension(".doc"), nil)
    }
    
    func test_type() {
        XCTAssertEqual(MediaExtension.bmp.type, MediaType.photo)
        XCTAssertEqual(MediaExtension.mov.type, MediaType.video)
    }
    
    func test_isPhoto() {
        XCTAssertEqual(MediaExtension.bmp.isPhoto, true)
        XCTAssertEqual(MediaExtension.jpg.isPhoto, true)
        
        XCTAssertEqual(MediaExtension.mov.isPhoto, false)
        XCTAssertEqual(MediaExtension.mp4.isPhoto, false)
    }
    
    func test_isVideo() {
        XCTAssertEqual(MediaExtension.mov.isVideo, true)
        XCTAssertEqual(MediaExtension.mp4.isVideo, true)

        XCTAssertEqual(MediaExtension.bmp.isVideo, false)
        XCTAssertEqual(MediaExtension.jpg.isVideo, false)
    }
    
    func test_extensions() {
        XCTAssertEqual(MediaExtension.jpg.extensions, ["jpg", "jpeg"])
        XCTAssertEqual(MediaExtension.mov.extensions, ["mov"])
    }
    
    func test_fileExtensions() {
        XCTAssertEqual(MediaExtension.jpg.fileExtensions, [".jpg", ".jpeg"])
        XCTAssertEqual(MediaExtension.mov.fileExtensions, [".mov"])
    }
    
    func test_ext() {
        XCTAssertEqual(MediaExtension.jpg.ext, "jpg")
        XCTAssertEqual(MediaExtension.mov.ext, "mov")
    }
    
    func test_fileExt() {
        XCTAssertEqual(MediaExtension.jpg.fileExt, ".jpg")
        XCTAssertEqual(MediaExtension.mov.fileExt, ".mov")
    }

}
