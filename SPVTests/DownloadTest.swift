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
    
    // MARK:- init
    func test_init() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertEqual(download.remoteURL, remoteURL)
        XCTAssertEqual(download.name, DownloadTest.filename)
        XCTAssertNil(download.task)
        XCTAssertNil(download.startTime)
        XCTAssertEqual(download.timeAccumulated, 0)
        XCTAssertEqual(download.bytesSinceResume, 0)
        XCTAssertEqual(download.totalSizeInBytes, 0)
        XCTAssertNil(download.index)
        XCTAssertEqual(download.isPaused, true)
        XCTAssertEqual(download.bytesDownloaded, 0)
    }
    
    // MARK:- progress.
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
    
    // MARK:- percentage
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
    
    // MARK:- complete
    func test_complete_false() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertEqual(download.complete, false)
    }
    
    func test_complete_true() {
        let download = Download(remoteURL: remoteURL)
        
        download.resume()
        download.completed(withMediaIndex: 0)
        
        XCTAssertEqual(download.complete, true)
    }
    
    // MARK:- bytesRemaining
    func test_bytesRemaining() {
        let download = Download(remoteURL: remoteURL)
        
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 375
        
        XCTAssertEqual(download.bytesRemaining, 625)
    }
    
    // MARK:- completed
    func test_completed() {
        let download = Download(remoteURL: remoteURL)
        
        download.resume()
        download.completed(withMediaIndex: 5)
        
        XCTAssertEqual(download.complete, true)
        XCTAssertEqual(download.index, 5)
    }
    
    // MARK:- pause
    func test_pause() {
        let download = Download(remoteURL: remoteURL)
        
        download.resume()
        download.pause();
        
        XCTAssertEqual(download.isPaused, true)
    }
    
    // MARK:- resume
    func test_resume() {
        let download = Download(remoteURL: remoteURL)
        
        download.resume()
        download.pause();
        download.resume();
        
        XCTAssertEqual(download.isPaused, false)
    }
    
    // MARK:- durationInSeconds
    func test_durationInSeconds_paused() {
        let date = Date()
        let download = Download(remoteURL: remoteURL)
        
        download.resume(at: date)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        download.pause(at: date.addingTimeInterval(20))
        
        XCTAssertEqual(download.durationInSeconds(at: date.addingTimeInterval(60)), 20)
    }
    
    func test_durationInSeconds_stopStart() {
        let date = Date()
        let download = Download(remoteURL: remoteURL)
        
        download.resume(at: date)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        download.pause(at: date.addingTimeInterval(20))
        download.resume(at: date.addingTimeInterval(30))
        
        XCTAssertEqual(download.durationInSeconds(at: date.addingTimeInterval(40)), 30)
    }
    
    func test_durationInSeconds_complete() {
        let date = Date()
        let download = Download(remoteURL: remoteURL)
        
        download.resume(at: date)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 1_000
        download.completed(withMediaIndex: 0,
                           at: date.addingTimeInterval(20))
        
        XCTAssertEqual(download.durationInSeconds(at: date.addingTimeInterval(60)), 20)
    }
    
    // MARK:- downloadSpeedInBPS
    func test_downloadSpeedInBPS_notStarted() {
        let download = Download(remoteURL: remoteURL)
        
        XCTAssertNil(download.downloadSpeedInBPS())
    }
    
    func test_downloadSpeedInBPS() {
        let date = Date()
        let download = Download(remoteURL: remoteURL)
        
        download.resume(at: date)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 100

        XCTAssertEqual(download.downloadSpeedInBPS(at: date.addingTimeInterval(10)), 10)
    }
    
    func test_downloadSpeedInBPS_paused() {
        let date = Date()
        let download = Download(remoteURL: remoteURL)
        
        download.resume(at: date)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 100
        download.pause(at: date.addingTimeInterval(10))

        XCTAssertNil(download.downloadSpeedInBPS())
    }

    // MARK:- timeRemainingInSeconds
    func test_timeRemainingInSeconds() {
        let date = Date()
        let download = Download(remoteURL: remoteURL)
        
        download.resume(at: date)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        
        XCTAssertEqual(download.timeRemainingInSeconds(at: date.addingTimeInterval(10)), 10)
    }
    
    func test_timeRemainingInSeconds_paused() {
        let date = Date()
        let download = Download(remoteURL: remoteURL)

        download.resume(at: date)
        download.totalSizeInBytes = 1_000
        download.bytesDownloaded = 500
        download.pause(at: date.addingTimeInterval(10))
        
        XCTAssertNil(download.timeRemainingInSeconds(at: date.addingTimeInterval(20)))
    }
    
    // MARK:- Helpers
    func waitForAsync(timeout: TimeInterval = 1,
                      isInverted: Bool = false,
                      action: (_ expectation: XCTestExpectation) -> Void) {
        let expect = expectation(description: "changedEvent is call when a property is updated")
        expect.isInverted = isInverted
        
        action(expect)
        
        waitForExpectations(timeout: timeout) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
}
