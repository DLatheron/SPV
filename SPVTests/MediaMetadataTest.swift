//
//  MediaMetadataTest.swift
//  SPV
//
//  Created by dlatheron on 05/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import XCTest
@testable import SPV

class MediaMetadataTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init_json() {
        let jsonString: String =
            "{\n" +
            "    \"rating\": 5,\n" +
            "    \"downloaded\": \"2017-09-05T07:52:00Z\",\n" +
            "    \"tags\": [\n" +
            "         \"Tag1\",\n" +
            "         \"Tag2\"\n" +
            "    ]\n" +
            "}"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let date = dateFormatter.date(from: "2017-09-05T07:52:00Z")
        
        let metadata = MediaMetadata(jsonString: jsonString)
        
        XCTAssertNotNil(metadata)
        XCTAssertEqual(metadata?.rating, 5)
        XCTAssertEqual(metadata?.dateDownloaded, date)
        XCTAssertEqual((metadata?.tags)!, ["Tag1", "Tag2"])
    }
}
