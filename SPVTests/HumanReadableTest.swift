//
//  HumanReadableTest.swift
//  SPV
//
//  Created by dlatheron on 29/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import XCTest
@testable import SPV

let KIBIBYTE: Int64 = 1024
let MEBIBYTE: Int64 = 1024 * 1024
let GIBIBYTE: Int64 = 1024 * 1024 * 1024
let TEBIBYTE: Int64 = 1024 * 1024 * 1024 * 1024
let PEBIBYTE: Int64 = 1024 * 1024 * 1024 * 1024 * 1024
let EXBIBYTE: Int64 = 1024 * 1024 * 1024 * 1024 * 1024 * 1024

let KILOBYTE: Int64 = 1024
let MEGABYTE: Int64 = 1024 * 1024
let GIGABYTE: Int64 = 1024 * 1024 * 1024
let TERABYTE: Int64 = 1024 * 1024 * 1024 * 1024
let PETABYTE: Int64 = 1024 * 1024 * 1024 * 1024 * 1024
let EXABYTE:  Int64 = 1024 * 1024 * 1024 * 1024 * 1024 * 1024

extension Double {
    var BYTES: Double { return self }
    
    var KIBIBYTES: Double { return self * Double(KIBIBYTE) }
    var MEBIBYTES: Double { return self * Double(MEBIBYTE) }
    var GIBIBYTES: Double { return self * Double(GIBIBYTE) }
    var TEBIBYTES: Double { return self * Double(TEBIBYTE) }
    var PEBIBYTES: Double { return self * Double(PEBIBYTE) }
    var EXBIBYTES: Double { return self * Double(EXBIBYTE) }
    
    var KILOBYTES: Double { return self * Double(KILOBYTE) }
    var MEGABYTES: Double { return self * Double(MEGABYTE) }
    var GIGABYTES: Double { return self * Double(GIGABYTE) }
    var TERABYTES: Double { return self * Double(TERABYTE) }
    var PETABYTES: Double { return self * Double(PETABYTE) }
    var EXABYTES: Double { return self * Double(EXABYTE) }
}


extension Int64 {
    var BYTES: Int64 { return self }
    
    var KIBIBYTES: Int64 { return self * KIBIBYTE }
    var MEBIBYTES: Int64 { return self * MEBIBYTE }
    var GIBIBYTES: Int64 { return self * GIBIBYTE }
    var TEBIBYTES: Int64 { return self * TEBIBYTE }
    var PEBIBYTES: Int64 { return self * PEBIBYTE }
    var EXBIBYTES: Int64 { return self * EXBIBYTE }
    
    var KILOBYTES: Int64 { return self * KILOBYTE }
    var MEGABYTES: Int64 { return self * MEGABYTE }
    var GIGABYTES: Int64 { return self * GIGABYTE }
    var TERABYTES: Int64 { return self * TERABYTE }
    var PETABYTES: Int64 { return self * PETABYTE }
    var EXABYTES: Int64 { return self * EXABYTE }
}

class HumanReadableTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // Class for size tests.
    // - Use si/non-si enumeration.
    
    class BytesTest {
        let expectedOutput: String
        let bytes: Int64?
        
        init(expectedOutput: String, bytes: Int64?) {
            self.expectedOutput = expectedOutput;
            self.bytes = bytes
        }
    }
    
    func test_bytes_pow2() {
        let tests = [
            BytesTest(expectedOutput: "-", bytes: nil),
            BytesTest(expectedOutput: "1 B", bytes: Int64(1).BYTES),
            BytesTest(expectedOutput: "999 B", bytes: Int64(999).BYTES),
            BytesTest(expectedOutput: "1,000 B", bytes: Int64(1_000).BYTES),
            BytesTest(expectedOutput: "2.0 KiB", bytes: Int64(2).KIBIBYTES),
            BytesTest(expectedOutput: "5.3 KiB", bytes: Int64(5_300).BYTES),
            BytesTest(expectedOutput: "2.0 MiB", bytes: Int64(2).MEBIBYTES),
            BytesTest(expectedOutput: "3.0 GiB", bytes: Int64(3).GIBIBYTES),
            BytesTest(expectedOutput: "4.0 TiB", bytes: Int64(4).TEBIBYTES),
            BytesTest(expectedOutput: "5.0 PiB", bytes: Int64(5).PEBIBYTES),
            BytesTest(expectedOutput: "6.0 EiB", bytes: Int64(6).EXBIBYTES)
        ]
        
        // Spaces.
        tests.forEach { test in
            XCTAssertEqual(
                HumanReadable.bytes(bytes: test.bytes,
                                    si: false,
                                    space: true
                ),
                test.expectedOutput)
        }
        
        // No spaces.
        tests.forEach { test in
            XCTAssertEqual(
                HumanReadable.bytes(bytes: test.bytes,
                                    si: false,
                                    space: false
                ),
                test.expectedOutput.replacingOccurrences(of: " ", with: ""))
        }
    }
    
    func test_bytes_pow10() {
        let tests = [
            BytesTest(expectedOutput: "-", bytes: nil),
            BytesTest(expectedOutput: "1.0 kB", bytes: Int64(1).KILOBYTES),
            BytesTest(expectedOutput: "2.0 kB", bytes: Int64(2).KILOBYTES),
            BytesTest(expectedOutput: "5.3 kB", bytes: Int64(5_300).BYTES),
            BytesTest(expectedOutput: "2.0 MB", bytes: Int64(2).MEGABYTES)
        ]
        
        // Spaces.
        tests.forEach { test in
            XCTAssertEqual(
                HumanReadable.bytes(bytes: test.bytes,
                                    si: true,
                                    space: true
                ),
                test.expectedOutput)
        }
        
        // No spaces.
        tests.forEach { test in
            XCTAssertEqual(
                HumanReadable.bytes(bytes: test.bytes,
                                    si: true,
                                    space: false
                ),
                test.expectedOutput.replacingOccurrences(of: " ", with: ""))
        }
    }
    
    
    class DurationTest {
        let expectedOutput: String
        let duration: TimeInterval?
        
        init(expectedOutput: String, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
            self.expectedOutput = expectedOutput
            self.duration = TimeInterval(hours * 60 * 60 + minutes * 60 + seconds)
        }

        init(expectedOutput: String, duration: TimeInterval?) {
            self.expectedOutput = expectedOutput
            self.duration = duration
        }
    }
    
    func test_duration() {
        let tests = [
            DurationTest(expectedOutput: "-", duration: nil),
            DurationTest(expectedOutput: "< 1 sec", seconds: 1),
            DurationTest(expectedOutput: "59 secs", seconds: 59),
            DurationTest(expectedOutput: "4:34", minutes: 4, seconds: 34),
            DurationTest(expectedOutput: "1:17:46", hours: 1, minutes: 17, seconds: 46)
        ]
        
        tests.forEach { test in
            XCTAssertEqual(HumanReadable.duration(duration: test.duration), test.expectedOutput)
        }
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
            BPSTest(bytesPerSecond: 0.5.BYTES, expectedOutput: "0.5 B/s"),
            BPSTest(bytesPerSecond: 1.5.BYTES, expectedOutput: "1.0 B/s"),
            BPSTest(bytesPerSecond: 50.0.BYTES, expectedOutput: "50.0 B/s"),
            BPSTest(bytesPerSecond: 5.0.KILOBYTES, expectedOutput: "5.0 KB/s"),
            BPSTest(bytesPerSecond: 4.0.MEGABYTES, expectedOutput: "4.0 MB/s"),
            BPSTest(bytesPerSecond: 3.0.GIGABYTES, expectedOutput: "3.0 GB/s"),
            BPSTest(bytesPerSecond: 2.0.TERABYTES, expectedOutput: "2.0 TB/s"),
            BPSTest(bytesPerSecond: 7.0.PETABYTES, expectedOutput: "7.0 PB/s"),
            BPSTest(bytesPerSecond: 6.0.EXABYTES, expectedOutput: "6.0 EB/s"),
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
