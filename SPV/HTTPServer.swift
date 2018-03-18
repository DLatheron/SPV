//
//  HTTPServer.swift
//  SPV
//
//  Created by dlatheron on 18/03/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import Swifter
import Dispatch

class HTTPServer {
    enum HTTPServerError: Error {
        case unableToDetermineServerAddress
    }
    
    static var shared: HTTPServer = HTTPServer()
    
    private let server = HttpServer()
    private let sessionQueue = DispatchQueue(label: "http queue")
    private let ipAddress = HTTPServer.GetIPAddress()
    
    init() {
        server["/"] = scopes {
            html {
                body {
                    center {
                        img { src = "https://swift.org/assets/images/swift.svg" }
                    }
                    
                    a {
                        href = "/files/"
                        inner = "Access Files"
                    }                    
                }
            }
        }
    }
    
    func activate() {
        sessionQueue.async {
            _ = self.startServer()
        }
    }
    
    private func startServer() -> String? {
        do {
            try self.server.start(9080, forceIPv4: true)
            
            self.server["/files/:path"] = directoryBrowser(HTTPServer.DocumentsDirectoryURL.path)
            
            let address = "\(self.ipAddress!):\(try self.server.port())"
            
            print("Server has started \(address). Try to connect now...")
            
            return address
        } catch {
            print("Server start error: \(error)")
            return nil
        }
    }
    
    func deactivate() {
        sessionQueue.async {
            self.server.stop()
        }
    }
    
    func toggle(completionBlock: @escaping (String?, Error?) -> ())  {
        sessionQueue.async {
            if self.server.operating {
                self.deactivate()
                completionBlock(nil, nil)
            } else {
                do {
                    if let address = self.startServer() {
                        completionBlock(address, nil)
                    } else {
                        throw HTTPServerError.unableToDetermineServerAddress
                    }
                } catch {
                    print("Failed to get server port: \(error)")
                    completionBlock(nil, error)
                }
            }
        }
    }
    
    class var DocumentsDirectoryURL: URL {
        get {
            let paths = FileManager.default.urls(for: .documentDirectory,
                                                 in: .userDomainMask)
            return paths[0] as URL
        }
    }
    
    private class func GetIPAddress() -> String? {
        var address: String?
        var ifaddr: UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while ptr != nil {
                defer { ptr = ptr?.pointee.ifa_next }
                
                let interface = ptr?.pointee
                let addrFamily = interface?.ifa_addr.pointee.sa_family
                if addrFamily == UInt8(AF_INET)/* || addrFamily == UInt8(AF_INET6)*/ {
                    
                    //if let name: String = String(cString: (interface?.ifa_name)!), name == "en0" {
                    var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                    getnameinfo(interface?.ifa_addr, socklen_t((interface?.ifa_addr.pointee.sa_len)!), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
                    address = String(cString: hostname)
                }
            }
            freeifaddrs(ifaddr)
        }
        return address
    }
}
