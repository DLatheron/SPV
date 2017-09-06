//
//  MediaInfoTest.swift
//  SPV
//
//  Created by dlatheron on 05/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import XCTest
@testable import SPV

class MediaInfoTest: XCTestCase {
    
    let defaultJSONString = JSONTestHelper.BuildJSON([
        "{",
        "  'title': 'A title',",
        "  'id': '2B7532EE-078F-43A1-8FC9-A739C1182F73',",
        "  'source': 'From whence it came',",
        "  'importDate': '2017-09-05T07:52:00Z',",
        "  'creationDate': '2018-10-05T07:52:00Z',",
        "  'fileSize': 4532,",
        "  'resolution': {",
        "     'width': 123,",
        "     'height': 456",
        "  },",
        "  'previousViews': 12,",
        "  'lastViewed': '2018-10-05T07:52:00Z',",
        "  'rating': 5,",
        "  'tags': [",
        "     'Tag1',",
        "     'Tag2'",
        "  ]",
        "}"
    ]);
    
    func validateDefault(mediaInfo: MediaInfo?) {
        let dateFormatter = ISO8601DateFormatter()
        let importDate = dateFormatter.date(from: "2017-09-05T07:52:00Z")
        let creationDate = dateFormatter.date(from: "2018-10-05T07:52:00Z")
        let lastViewedDate = dateFormatter.date(from: "2018-10-05T07:52:00Z")
        
        XCTAssertNotNil(mediaInfo)
        XCTAssertEqual(mediaInfo?.title, "A title")
        XCTAssertEqual(mediaInfo?.id, UUID(uuidString: "2B7532EE-078F-43A1-8FC9-A739C1182F73"))
        XCTAssertEqual(mediaInfo?.source, "From whence it came")
        XCTAssertEqual(mediaInfo?.importDate, importDate)
        XCTAssertEqual(mediaInfo?.creationDate, creationDate)
        XCTAssertEqual(mediaInfo?.fileSize, 4532)
        XCTAssertEqual(mediaInfo?.resolution.width, 123)
        XCTAssertEqual(mediaInfo?.resolution.height, 456)
        XCTAssertEqual(mediaInfo?.previousViews, 12)
        XCTAssertEqual(mediaInfo?.lastViewed, lastViewedDate)
        XCTAssertEqual(mediaInfo?.rating, 5)
        XCTAssertEqual((mediaInfo?.tags)!, ["Tag1", "Tag2"])
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init_json() {
        let mediaInfo = MediaInfo(jsonString: defaultJSONString)
        
        validateDefault(mediaInfo: mediaInfo)
    }
    
    func test_makeJSONString() {
        let mediaInfo = MediaInfo(jsonString: defaultJSONString)!
        let jsonString = mediaInfo.makeJSONString()
        let newMediaInfo = MediaInfo(jsonString: jsonString)!
        
        validateDefault(mediaInfo: newMediaInfo)
    }
}
