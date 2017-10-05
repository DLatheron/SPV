//
//  URLBuilder.swift
//  SPV
//
//  Created by dlatheron on 05/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class URLBuilder {
    let defaultScheme = "http"
    let secureSchemes = [
        "https",
        "sftp"
    ]
    
    var scheme: String?
    var user: String?
    var password: String?
    var host: String?
    var port: Int?
    var path: String?
    var query: String?
    var fragment: String?

    var url: URL? {
        get {
            return buildURL()
        }
    }
    
    var string: String? {
        get {
            return buildURL()?.absoluteString
        }
    }
    
    var isSchemeSecure: Bool {
        get {
            if let scheme = scheme {
                return secureSchemes.index(of: scheme) != nil
            } else {
                return false
            }
        }
    }
    
    var isValid: Bool {
        get {
            return url != nil
        }
    }
    
    init(scheme: String? = nil,
         user: String? = nil,
         password: String? = nil,
         host: String? = nil,
         port: Int? = nil,
         path: String? = "",
         query: String? = nil,
         fragment: String? = nil) {
        self.scheme = scheme
        self.host = host
        self.port = port
        self.path = path
        self.fragment = fragment
        self.query = query
        self.user = user
        self.password = password
    }
    
    convenience init?(scheme: String? = nil,
                      host: String? = nil,
                      path: String? = nil) {
        self.init()
        
        self.scheme = scheme
        self.host = host
        self.path = path
    }
    
    convenience init?(string: String) {
        self.init()
        
        if let urlComponents = NSURLComponents(string: string) {
            self.scheme = urlComponents.scheme
            self.host = urlComponents.host
            if let portNumber = urlComponents.port {
                self.port = portNumber.intValue
            }
            self.path = urlComponents.path
            self.query = urlComponents.query
            self.fragment = urlComponents.fragment
            self.user = urlComponents.user
            self.password = urlComponents.password
        }
    }
    
    private func buildURL() -> URL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = scheme ?? defaultScheme
        urlComponents.user = user
        urlComponents.password = password
        urlComponents.host = host
        if let port = port { urlComponents.port = NSNumber(value: port) }
        urlComponents.path = path
        urlComponents.query = query
        urlComponents.fragment = fragment

        return urlComponents.url
    }
}
