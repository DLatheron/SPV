//
//  URLBuilderTests.swift
//  SPVTests
//
//  Created by dlatheron on 05/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import XCTest
@testable import SPV

class URLBuilderTests : XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_init_fromComponents() {
        let urlBuilder = URLBuilder(scheme: "https",
                                    user: "user",
                                    password: "secret",
                                    host: "google.co.uk",
                                    port: 80,
                                    path: "/default.html",
                                    query: "search=hello world",
                                    fragment: "fragment")
        
        XCTAssertEqual(urlBuilder.string, "https://user:secret@google.co.uk:80/default.html?search=hello%20world#fragment");
    }
    
    func test_init_simple() {
        let urlBuilder = URLBuilder(scheme: "http",
                                    host: "microsoft",
                                    path: "/index.html")
        
        XCTAssertEqual(urlBuilder!.string, "http://microsoft.co.uk/index.html");
    }
}
