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
    
    class BPSTest {
        let bytesPerSecond: Double?
        let expectedOutput: String
        
        init(bitsPerSecond: Double?,
             expectedOutput: String) {
            self.bytesPerSecond = bitsPerSecond == nil ? nil : bitsPerSecond! * 8
            self.expectedOutput = expectedOutput
        }
        
        init(bytesPerSecond: Double?,
             expectedOutput: String) {
            self.bytesPerSecond = bytesPerSecond
            self.expectedOutput = expectedOutput
        }
    }
    
    func test_bps_bits() {
        let tests = [
            BPSTest(bitsPerSecond: nil, expectedOutput: "-"),
            BPSTest(bitsPerSecond: 0.5, expectedOutput: "0.5 bps"),
            BPSTest(bitsPerSecond: 1, expectedOutput: "1.0 bps"),
            BPSTest(bitsPerSecond: 50, expectedOutput: "50.0 bps"),
            BPSTest(bitsPerSecond: 5_000, expectedOutput: "5.0 Kbps"),
            BPSTest(bitsPerSecond: 4_000_000, expectedOutput: "4.0 Mbps"),
            BPSTest(bitsPerSecond: 3_000_000_000, expectedOutput: "3.0 Gbps"),
            BPSTest(bitsPerSecond: 2_000_000_000_000, expectedOutput: "2.0 Tbps"),
            BPSTest(bitsPerSecond: 7_000_000_000_000_000, expectedOutput: "7.0 Pbps"),
            BPSTest(bitsPerSecond: 6_000_000_000_000_000_000, expectedOutput: "6.0 Ebps"),
        ]
        let bpsUnits = HumanReadable.BPSUnits.bitsPerSecond
        
        // Spaces.
        tests.forEach { test in
            XCTAssertEqual(HumanReadable.bps(
                bytesPerSecond: test.bytesPerSecond,
                units: bpsUnits,
                space: true
            ), test.expectedOutput)
        }
        
        // No spaces.
        tests.forEach { test in
            XCTAssertEqual(HumanReadable.bps(
                bytesPerSecond: test.bytesPerSecond,
                units: bpsUnits,
                space: false
            ), test.expectedOutput.replacingOccurrences(of: " ", with: ""))
        }
    }
    
    func test_bps_siBytes() {
        let tests = [
            BPSTest(bytesPerSecond: nil, expectedOutput: "-"),
            BPSTest(bytesPerSecond: 0.5, expectedOutput: "0.5 B/s"),
            BPSTest(bytesPerSecond: 1, expectedOutput: "1.0 B/s"),
            BPSTest(bytesPerSecond: 50, expectedOutput: "50.0 B/s"),
            BPSTest(bytesPerSecond: 5_000, expectedOutput: "5.0 KB/s"),
            BPSTest(bytesPerSecond: 4_000_000, expectedOutput: "4.0 MB/s"),
            BPSTest(bytesPerSecond: 3_000_000_000, expectedOutput: "3.0 GB/s"),
            BPSTest(bytesPerSecond: 2_000_000_000_000, expectedOutput: "2.0 TB/s"),
            BPSTest(bytesPerSecond: 7_000_000_000_000_000, expectedOutput: "7.0 PB/s"),
            BPSTest(bytesPerSecond: 6_000_000_000_000_000_000, expectedOutput: "6.0 EB/s"),
        ]
        let bpsUnits = HumanReadable.BPSUnits.siBytesPerSecond
        
        // Spaces.
        tests.forEach { test in
            XCTAssertEqual(HumanReadable.bps(
                bytesPerSecond: test.bytesPerSecond,
                units: bpsUnits,
                space: true
            ), test.expectedOutput)
        }
        
        // No spaces.
        tests.forEach { test in
            XCTAssertEqual(HumanReadable.bps(
                bytesPerSecond: test.bytesPerSecond,
                units: bpsUnits,
                space: false
            ), test.expectedOutput.replacingOccurrences(of: " ", with: ""))
        }
    }

    func test_bps_bytes() {
        let KILOBYTE: Double = 1024
        let MEGABYTE: Double = 1024 * 1024
        let GIGABYTE: Double = 1024 * 1024 * 1024
        let TERABYTE: Double = 1024 * 1024 * 1024 * 1024
        let PETABYTE: Double = 1024 * 1024 * 1024 * 1024 * 1024
        let EXABYTE:  Double = 1024 * 1024 * 1024 * 1024 * 1024 * 1024
        
        let tests = [
            BPSTest(bytesPerSecond: nil, expectedOutput: "-"),
            BPSTest(bytesPerSecond: 0.5, expectedOutput: "0.5 B/s"),
            BPSTest(bytesPerSecond: 1, expectedOutput: "1.0 B/s"),
            BPSTest(bytesPerSecond: 50, expectedOutput: "50.0 B/s"),
            BPSTest(bytesPerSecond: 5 * KILOBYTE, expectedOutput: "5.0 KiB/s"),
            BPSTest(bytesPerSecond: 4 * MEGABYTE, expectedOutput: "4.0 MiB/s"),
            BPSTest(bytesPerSecond: 3 * GIGABYTE, expectedOutput: "3.0 GiB/s"),
            BPSTest(bytesPerSecond: 2 * TERABYTE, expectedOutput: "2.0 TiB/s"),
            BPSTest(bytesPerSecond: 7 * PETABYTE, expectedOutput: "7.0 PiB/s"),
            BPSTest(bytesPerSecond: 6 * EXABYTE, expectedOutput: "6.0 EiB/s"),
        ]
        let bpsUnits = HumanReadable.BPSUnits.bytesPerSecond
        
        // Spaces.
        tests.forEach { test in
            XCTAssertEqual(HumanReadable.bps(
                bytesPerSecond: test.bytesPerSecond,
                units: bpsUnits,
                space: true
            ), test.expectedOutput)
        }
        
        // No spaces.
        tests.forEach { test in
            XCTAssertEqual(HumanReadable.bps(
                bytesPerSecond: test.bytesPerSecond,
                units: bpsUnits,
                space: false
            ), test.expectedOutput.replacingOccurrences(of: " ", with: ""))
        }
    }
}
