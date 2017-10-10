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
                                    host: "microsoft.co.uk",
                                    path: "/index.html")
        
        XCTAssertEqual(urlBuilder!.string, "http://microsoft.co.uk/index.html");
    }
    
    func test_init_string() {
        let urlBuilder = URLBuilder(string: "http://user:password@google.com:8080/account/logon?search=Holiday%20dates#title")!
        
        XCTAssertEqual(urlBuilder.scheme, "http")
        XCTAssertEqual(urlBuilder.user, "user")
        XCTAssertEqual(urlBuilder.password, "password")
        XCTAssertEqual(urlBuilder.host, "google.com")
        XCTAssertEqual(urlBuilder.port, 8080)
        XCTAssertEqual(urlBuilder.path, "/account/logon")
        XCTAssertEqual(urlBuilder.query, "search=Holiday dates")
        XCTAssertEqual(urlBuilder.fragment, "title")
    }
    
    func test_isSchemeSecure() {
        XCTAssertEqual(URLBuilder(string: "http://www.google.co.uk/")!.isSchemeSecure, false)
        XCTAssertEqual(URLBuilder(string: "ftp://www.google.co.uk/")!.isSchemeSecure, false)
        XCTAssertEqual(URLBuilder(string: "https://www.google.co.uk/")!.isSchemeSecure, true)
        XCTAssertEqual(URLBuilder(string: "sftp://www.google.co.uk/")!.isSchemeSecure, true)
    }
    
    
}
