//
//  DownloadTest.swift
//  SPV
//
//  Created by dlatheron on 25/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import XCTest
@testable import SPV

class DownloadTest: XCTestCase {
    static let filename = "index.jpg"
    let remoteURL = URL(string: "http://www.example.com/\(filename)")!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertEqual(download.remoteURL, remoteURL)
        XCTAssertEqual(download.name, DownloadTest.filename)
        XCTAssertEqual(download.totalSizeInBytes, 0)
        XCTAssertEqual(download.bytesDownloaded, 0)
        XCTAssertNotNil(download.startTime)
        XCTAssertNil(download.endTime)
        XCTAssertNil(download.index)
    }
    
    func test_totalSizeInBytesHumanReadable() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertEqual(download.totalSizeInBytesHumanReadable, "0 bytes")
    }
    
    func test_progress_zero() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertEqual(download.progress, 0.0)
    }
    
    func test_progress_50percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        
        XCTAssertEqual(download.progress, 0.5)
    }
    
    func test_progress_100percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 1_000
        
        XCTAssertEqual(download.progress, 1.0)
    }
    
    func test_progress_over100percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 2_000
        
        XCTAssertEqual(download.progress, 1.0)
    }
}
