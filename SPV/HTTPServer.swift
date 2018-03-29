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
//        server["/"] = scopes {
//            html {
//                body {
//                    center {
//                        img { src = "https://swift.org/assets/images/swift.svg" }
//                    }
//
//                    a {
//                        href = "/files/"
//                        inner = "Access Files"
//                    }
//                }
//            }
//        }
        let serverRootURL = Bundle.main.resourceURL!.appendingPathComponent("ServerRoot/");
        
        server["/"] = shareFile(serverRootURL.appendingPathComponent("index.html").path)
        server["/html/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("html/").path)
        server["/lib/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("lib/").path)
        server["/css/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("css/").path)
        server["/favicon/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("favicon/").path)
        server["/src/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("src/").path)
        server["/imageCount"] = { (HttpRequest) -> HttpResponse in
            // TODO: Return the number of images in a JSON blob...
            print("Request received")
            
            return HttpResponse.internalServerError
        }
        server["/images"] = { (HttpRequest) -> HttpResponse in
            print("Request received")
            
            // TODO: Access sort, direction, skip and limit to form the query.
            
            return HttpResponse.internalServerError
        }
        server["/downloadImages"] = { (HttpRequest) -> HttpResponse in
            print("Request received")
            
            // TODO: Work out what we need to zip and create a job for it...
            
            return HttpResponse.internalServerError
        }
        server["/downloadProgress/:id"] = { (HttpRequest) -> HttpResponse in
            print("Request received")
            
            // TODO: Work out what we need to zip and create a job for it...
            
            return HttpResponse.internalServerError
        }
        server["/downloads/:id/:file.zip"] = { (HttpRequest) -> HttpResponse in
            print("Request received")
            
            // TODO: Work out what we need to zip and create a job for it...
            
            return HttpResponse.internalServerError
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
    
    public func serveFilesFromDirectory(_ directoryPath: String,
                                        defaults: [String] = ["index.html", "default.html"]) -> ((HttpRequest) -> HttpResponse) {
        return { r in
            guard let fileRelativePath = r.params.first else {
                return .notFound
            }
            if fileRelativePath.value.isEmpty {
                for path in defaults {
                    if let file = try? (directoryPath + String.pathSeparator + path).openForReading() {
                        return .raw(200, "OK", [:], { writer in
                            try? writer.write(file)
                            file.close()
                        })
                    }
                }
            }
            if let file = try? (directoryPath + String.pathSeparator + fileRelativePath.value).openForReading() {
                let headers: [String:String]?
                
                switch (fileRelativePath.value as NSString).pathExtension.lowercased() {
                case "js": headers = ["Content-type":"application/javascript"]
                case "html": headers = ["Content-type":"text/html"]
                case "json": headers = ["Content-type":"application/json"]
                case "css": headers = ["Content-type":"text/css"]
                case "jpg": headers = ["Content-type":"image/jpeg"]
                case "jpeg": headers = ["Content-type":"image/jpeg"]
                case "png": headers = ["Content-type":"image/png"]
                case "gif": headers = ["Content-type":"image/gif"]
                default: headers = ["Content-type":"text/plain"]
                }
                
                return .raw(200, "OK", headers, { writer in
                    try? writer.write(file)
                    file.close()
                })
            }
            return .notFound
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
