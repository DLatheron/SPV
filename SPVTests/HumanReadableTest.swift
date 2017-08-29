//
//  HumanReadableTest.swift
//  SPV
//
//  Created by dlatheron on 29/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import XCTest
@testable import SPV

class HumanReadableTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func test_bytes_nonSI() {
        XCTAssertEqual(HumanReadable.bytes(bytes: nil), "-")
        XCTAssertEqual(HumanReadable.bytes(bytes: 1_000), "1,000B")
        XCTAssertEqual(HumanReadable.bytes(bytes: 2_000), "2.0KiB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 5_300), "5.2KiB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 2_000_000), "1.9MiB")
        
        XCTAssertEqual(HumanReadable.bytes(bytes: nil, space: true), "-")
        XCTAssertEqual(HumanReadable.bytes(bytes: 1_000, space: true), "1,000 B")
        XCTAssertEqual(HumanReadable.bytes(bytes: 2_000, space: true), "2.0 KiB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 5_300, space: true), "5.2 KiB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 2_000_000, space: true), "1.9 MiB")
    }
    
    func test_bytes_si() {
        XCTAssertEqual(HumanReadable.bytes(bytes: nil, si: true), "-")
        XCTAssertEqual(HumanReadable.bytes(bytes: 1_000, si: true), "1.0kB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 2_000, si: true), "2.0kB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 5_300, si: true), "5.3kB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 2_000_000, si: true), "2.0MB")
        
        XCTAssertEqual(HumanReadable.bytes(bytes: nil, si: true, space: true), "-")
        XCTAssertEqual(HumanReadable.bytes(bytes: 1_000, si: true, space: true), "1.0 kB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 2_000, si: true, space: true), "2.0 kB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 5_300, si: true, space: true), "5.3 kB")
        XCTAssertEqual(HumanReadable.bytes(bytes: 2_000_000, si: true, space: true), "2.0 MB")
    }
    
    // Tests for human readable duration.
    func test_duration() {
        let oneHourPlus = TimeInterval(exactly: (((1 * 60) + 17) * 60) + 46)
        let almostOneMinute = TimeInterval(exactly: 59)
        let almostFiveMinutes = TimeInterval(exactly: (4 * 60) + 34)
        
        XCTAssertEqual(HumanReadable.duration(duration: nil), "-")
        XCTAssertEqual(HumanReadable.duration(duration: TimeInterval(exactly: 1)), "< 1 sec")
        XCTAssertEqual(HumanReadable.duration(duration: almostOneMinute), "59 secs")
        XCTAssertEqual(HumanReadable.duration(duration: almostFiveMinutes), "4:34")
        XCTAssertEqual(HumanReadable.duration(duration: oneHourPlus), "1:17:46")
    }
    
    // Tests for human readable BPS.
    class BPSTest {
        let bytesPerSecond: Int64?
        let expectedOutput: String
        let units: HumanReadable.BPSUnits
        let space: Bool
        
        init(bitsPerSecond: Int64?,
             expectedOutput: String) {
            self.bytesPerSecond = bitsPerSecond == nil ? nil : bitsPerSecond! * 8
            self.expectedOutput = expectedOutput
            self.units = HumanReadable.BPSUnits.bitsPerSecond
            self.space = false
        }
        
        init(bytesPerSecond: Int64?,
             expectedOutput: String) {
            self.bytesPerSecond = bytesPerSecond
            self.expectedOutput = expectedOutput
            self.units = HumanReadable.BPSUnits.bytesPerSecond
            self.space = false
        }
    }
    
    func test_bps_bits() {
        let tests = [
            BPSTest(bitsPerSecond: nil, expectedOutput: "-"),
            BPSTest(bitsPerSecond: 50, expectedOutput: "50.0bps"),
            BPSTest(bitsPerSecond: 5_000, expectedOutput: "5.0Kbps"),
            BPSTest(bitsPerSecond: 4_000_000, expectedOutput: "4.0Mbps"),
            BPSTest(bitsPerSecond: 3_000_000_000, expectedOutput: "3.0Gbps"),
            BPSTest(bitsPerSecond: 2_000_000_000_000, expectedOutput: "2.0Tbps"),
            BPSTest(bitsPerSecond: 7_000_000_000_000_000, expectedOutput: "7.0Pbps"),
            BPSTest(bitsPerSecond: 6_000_000_000_000_000_000, expectedOutput: "6.0Ebps"),
        ]
        
        for test in tests.enumerated() {
            XCTAssertEqual(HumanReadable.bps(
                bytesPerSecond: test.bytesPerSecond,
                units: test.units,
                space: test.space
            ), test.expectedOutput)
        }
        
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: nil), "-")
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: 8 * 50), "50.0bps")
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: 8 * 5_000), "5.0Kbps")
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: 8 * 4_000_000), "4.0Mbps")
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: 8 * 3_000_000_000), "3.0Gbps")
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: 8 * 2_000_000_000_000), "2.0Tbps")
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: 8 * 7_000_000_000_000_000), "7.0Pbps")
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: 8 * 6_000_000_000_000_000_000), "6.0Ebps")
    }
    
    func test_bps_si() {
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: nil, units: .siBytesPerSecond), "-")
        XCTAssertEqual(HumanReadable.bps(bytesPerSecond: 50, units: .siBytesPerSecond), "50.0B/s")
    }
    
    func test_bps_bytes() {
        
    }
}
