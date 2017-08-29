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
    
//    func test_durationHumanReadable_validDuration() {
//        let download = Download(remoteURL: remoteURL)
//        
//        download.pause = false
//        let date = Date()
//        download.startTime = date
//        download.endTime = date.addingTimeInterval(20)
//        
//        XCTAssertEqual(download.durationHumanReadable, "20.0s")
//    }
    
//    func test_durationHumanReadable_invalidDuration() {
//        let download = Download(remoteURL: remoteURL)
//        
//        download.pause = true
//        
//        XCTAssertEqual(download.durationHumanReadable, "-")
//    }
    
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
    
    func test_humanReadableBytes_nonSI() {
        XCTAssertEqual(Download.humanReadableBytes(bytes: nil), "-")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 1_000), "1,000B")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 2_000), "2.0KiB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 5_300), "5.2KiB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 2_000_000), "1.9MiB")
        
        XCTAssertEqual(Download.humanReadableBytes(bytes: nil, space: true), "-")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 1_000, space: true), "1,000 B")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 2_000, space: true), "2.0 KiB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 5_300, space: true), "5.2 KiB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 2_000_000, space: true), "1.9 MiB")
    }
    
    func test_humanReadableBytes_si() {
        XCTAssertEqual(Download.humanReadableBytes(bytes: nil, si: true), "-")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 1_000, si: true), "1.0kB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 2_000, si: true), "2.0kB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 5_300, si: true), "5.3kB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 2_000_000, si: true), "2.0MB")
        
        XCTAssertEqual(Download.humanReadableBytes(bytes: nil, si: true, space: true), "-")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 1_000, si: true, space: true), "1.0 kB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 2_000, si: true, space: true), "2.0 kB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 5_300, si: true, space: true), "5.3 kB")
        XCTAssertEqual(Download.humanReadableBytes(bytes: 2_000_000, si: true, space: true), "2.0 MB")
    }
    
    // Tests for human readable duration.
    func test_humanReadableDuration() {
        let oneHourPlus = TimeInterval(exactly: (((1 * 60) + 17) * 60) + 46)
        let almostOneMinute = TimeInterval(exactly: 59)
        let almostFiveMinutes = TimeInterval(exactly: (4 * 60) + 34)
        
        XCTAssertEqual(Download.humanReadableDuration(duration: nil), "-")
        XCTAssertEqual(Download.humanReadableDuration(duration: TimeInterval(exactly: 1)), "< 1 sec")
        XCTAssertEqual(Download.humanReadableDuration(duration: almostOneMinute), "59 secs")
        XCTAssertEqual(Download.humanReadableDuration(duration: almostFiveMinutes), "4:34")
        XCTAssertEqual(Download.humanReadableDuration(duration: oneHourPlus), "1:17:46")
    }
    
    // Tests for human readable BPS.
    func test_humanReadableBPS_bps() {
        XCTAssertEqual(Download.humanReadableBPS(bytesPerSecond: nil), "-")
        XCTAssertEqual(Download.humanReadableBPS(bytesPerSecond: 50), "50.0bps")
        XCTAssertEqual(Download.humanReadableBPS(bytesPerSecond: 5_000), "5.0Kbps")
        
        XCTAssertEqual(Download.humanReadableBPS(bytesPerSecond: 4_000_000), "4.0Mbps")
        XCTAssertEqual(Download.humanReadableBPS(bytesPerSecond: 3_000_000_000), "3.0Gbps")
        XCTAssertEqual(Download.humanReadableBPS(bytesPerSecond: 2_000_000_000_000), "2.0Tbps")
        XCTAssertEqual(Download.humanReadableBPS(bytesPerSecond: 7_000_000_000_000_000), "7.0Pbps")
        XCTAssertEqual(Download.humanReadableBPS(bytesPerSecond: 6_000_000_000_000_000_000), "6.0Ebps")
    }
    
    func test_humanReadableBPS_siBytesPerSecond() {
        
    }
    
    func test_humanReadableBPS_bytesPerSecond() {
        
    }
}
