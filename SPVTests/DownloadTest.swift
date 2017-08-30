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
    
    // MARK: - init
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
    
    // MARK: - progress.
    func test_progress_0percent() {
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
    
    // MARK: - percentage
    func test_percentage_0percent() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertEqual(download.percentage, 0.0)
    }
    
    func test_percentage_50percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        
        XCTAssertEqual(download.percentage, 50.0)
    }
    
    func test_percentage_100percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 1_000
        
        XCTAssertEqual(download.percentage, 100.0)
    }
    
    func test_percentage_over100percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 2_000
        
        XCTAssertEqual(download.percentage, 100.0)
    }
    
    func test_complete_0percent() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertEqual(download.complete, false)
    }
    
    func test_complete_50percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        
        XCTAssertEqual(download.complete, false)
    }
    
    func test_complete_100percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 1_000
        
        XCTAssertEqual(download.complete, true)
    }
    
    func test_complete_over100percent() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 2_000
        
        XCTAssertEqual(download.complete, true)
    }
    
    func test_bytesRemaining() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 375
        
        XCTAssertEqual(download.bytesRemaining, 625)
    }
    
    func test_durationInSeconds_nil() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertNil(download.durationInSeconds)
    }
    
    func test_durationInSeconds() {
        let download = Download(remoteURL: remoteURL)
        
        download.pause = false
        let date = Date()
        download.startTime = date
        download.endTime = date.addingTimeInterval(20)
        
        XCTAssertEqual(download.durationInSeconds, 20)
    }
    
    func test_downloadSpeedInBPS() {
        let download = Download(remoteURL: remoteURL)
        
        download.pause = false
        let date = Date()
        download.startTime = date
        download.endTime = date.addingTimeInterval(10)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 100
        
        XCTAssertEqual(download.downloadSpeedInBPS, 10)
    }
    
    func test_downloadSpeedInBPS_paused() {
        let download = Download(remoteURL: remoteURL)

        download.pause = true
        
        XCTAssertNil(download.downloadSpeedInBPS)
    }

    func test_timeRemainingInSeconds() {
        let download = Download(remoteURL: remoteURL)
        
        download.pause = false
        let date = Date()
        download.startTime = date
        download.endTime = date.addingTimeInterval(10)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        
        XCTAssertEqual(download.timeRemainingInSeconds, 10)
    }
    
    func test_timeRemainingInSeconds_paused() {
        let download = Download(remoteURL: remoteURL)
        
        download.pause = true
        let date = Date()
        download.startTime = date
        download.endTime = date.addingTimeInterval(10)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        
        XCTAssertNil(download.timeRemainingInSeconds)
    }
    
    func test_totalSizeInBytes_changed() {
        let download = Download(remoteURL: remoteURL)
        
        let expect = expectation(description: "changedEvent is call when a property is updated")
        
        download.changedEvent = { (propertyName) in
            XCTAssertEqual(propertyName, "totalSizeInBytes")
            expect.fulfill()
        }
        
        download.totalSizeInBytes = 34
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
    func test_totalSizeInBytes_noChange() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 34

        download.changedEvent = { (propertyName) in
            XCTFail("Change event should not have fired")
        }
        
        download.totalSizeInBytes = 34
    }
}
