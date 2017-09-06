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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init_json() {
        let jsonString = JSONTestHelper.BuildJSON([
            "{",
            "  'title': 'A title',",
            "  'id': '2B7532EE-078F-43A1-8FC9-A739C1182F73',",
            "  'source': 'From whence it came',",
            "  'rating': 5,",
            "  'importDate': '2017-09-05T07:52:00Z',",
            "  'creationDate': '2018-10-05T07:52:00Z',",
            "  'tags': [",
            "     'Tag1',",
            "     'Tag2'",
            "  ]",
            "}"
        ]);

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        let importDate = dateFormatter.date(from: "2017-09-05T07:52:00Z")
        let creationDate = dateFormatter.date(from: "2018-10-05T07:52:00Z")
        
        let info = MediaInfo(jsonString: jsonString)
        
        XCTAssertNotNil(info)
        XCTAssertEqual(info?.title, "A title")
        XCTAssertEqual(info?.id, UUID(uuidString: "2B7532EE-078F-43A1-8FC9-A739C1182F73"))
        XCTAssertEqual(info?.source, "From whence it came")
        XCTAssertEqual(info?.importDate, importDate)
        XCTAssertEqual(info?.creationDate, creationDate)
        XCTAssertEqual(info?.rating, 5)
        XCTAssertEqual((info?.tags)!, ["Tag1", "Tag2"])
    }
}
