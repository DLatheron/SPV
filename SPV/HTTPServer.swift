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
import SwiftyJSON
import Zip

class ZipOperation {
    let downloadId: UUID
    let zipArchiveURL: URL
    
    var fileURLs: [URL] = []
    var progress: Double = 0
    
    init() {
        self.downloadId = UUID()
        
        try? FileManager.default.createDirectory(at: HTTPServer.DocumentsDirectoryURL.appendingPathComponent("Downloads/"),
                                                 withIntermediateDirectories: false,
                                                 attributes: nil)
        
        self.zipArchiveURL = HTTPServer.DocumentsDirectoryURL.appendingPathComponent("Downloads/\(downloadId).zip")
    }
    
    func add(url: URL) {
        fileURLs.append(url)
    }
    
    func beginZip() -> Bool {
        if fileURLs.count > 0 {
            try? Zip.zipFiles(paths: fileURLs,
                              zipFilePath: zipArchiveURL,
                              password: nil,
                              progress: self.updateProgress)
            return true
        } else {
            return false
        }
    }
    
    private func updateProgress(_ progress: Double) {
        self.progress = progress
    }
}

class HTTPServer {
    enum HTTPServerError: Error {
        case unableToDetermineServerAddress
    }
    
    static var shared: HTTPServer = HTTPServer()
    
    private let server = HttpServer()
    private let sessionQueue = DispatchQueue(label: "http queue")
    private let ipAddress = HTTPServer.GetIPAddress()
    private var zipOperations: [UUID: ZipOperation] = [:]
    
    init() {
        let serverRootURL = Bundle.main.resourceURL!.appendingPathComponent("ServerRoot/");
        let mediaManager = MediaManager.shared
        
        server["/"] = shareFile(serverRootURL.appendingPathComponent("index.html").path)
        server["/livephoto/:id"] = { (request: HttpRequest) -> HttpResponse in
            if let idParam = request.params[":id"] {
                if let uuid = UUID(uuidString: idParam) {
                    if let media = mediaManager.getMedia(byId: uuid) {
                        let width = media.mediaInfo.resolution.width / 5
                        let height = media.mediaInfo.resolution.height / 5
                        
                        return self.returnTemplatedFile(
                            serverRootURL.appendingPathComponent("livephoto.html").path,
                            templates: [
                                "%width%": "\(width)",
                                "%height%": "\(height)",
                                "%photo-src%": "/image/\(media.id)",
                                "%video-src%": "/video/\(media.id)",
                                "%url%": "/image/\(media.id)"
                           ]
                        )
                    }
                }
            }
            return .notFound
        }
        server["/html/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("html/").path)
        server["/lib/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("lib/").path)
        server["/css/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("css/").path)
        server["/favicon/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("favicon/").path)
        server["/src/:path"] = serveFilesFromDirectory(serverRootURL.appendingPathComponent("src/").path)
        server["/imageCount"] = { (HttpRequest) -> HttpResponse in
            let json: [String:Any] = [
                "totalImages": mediaManager.count
            ]
            
            return self.sendJSON(json as AnyObject)
        }
        server["/thumbnail/:id"] = { (request: HttpRequest) -> HttpResponse in
            if let idParam = request.params[":id"] {
                if let uuid = UUID(uuidString: idParam) {
                    if let media = mediaManager.getMedia(byId: uuid) {
                        return self.serve(filename: media.fileURL.path)
                    }
                }
            }
            return .notFound
        }
        server["/image/:id"] = { (request: HttpRequest) -> HttpResponse in
            if let idParam = request.params[":id"] {
                if let uuid = UUID(uuidString: idParam) {
                    if let media = mediaManager.getMedia(byId: uuid) {
                        return self.serve(filename: media.getImageURL.path)
                    }
                }
            }
            return .notFound
        }
        server["/video/:id"] = { (request: HttpRequest) -> HttpResponse in
            if let idParam = request.params[":id"] {
                if let uuid = UUID(uuidString: idParam) {
                    if let media = mediaManager.getMedia(byId: uuid) {
                        switch media {
                        case let media as LivePhoto:
                            return self.serve(filename: media.videoURL.path)
                        case let media as Video:
                            return self.serve(filename: media.fileURL.path)
                        default:
                            return .notFound
                        }
                    }
                }
            }
            return .notFound
        }
        server["/images"] = { (request: HttpRequest) -> HttpResponse in
            // TODO: Access all of the media, sort it, pull the limit number from the offset and return
            // those as a JSON blob.
            let mediaCollection = mediaManager.media
            
            let paramSort = request.queryParams.first(where: { $0.0 == "sort" })?.1 ?? "date"
            let paramDirection = request.queryParams.first(where: { $0.0 == "direction" })?.1 ?? "ascending"
            let paramSkip = request.queryParams.first(where: { $0.0 == "skip" })?.1 ?? "0"
            let paramLimit = request.queryParams.first(where: { $0.0 == "limit" })?.1
            
            let sortBy: SortBy
            
            switch paramSort {
            case "name": sortBy = .Name
            case "natural": sortBy = .None
            case "date": sortBy = .Added
            case "size": sortBy = .Size
            case "rating": sortBy = .Rating
            default: sortBy = .Created
            }
            
            let direction = (paramDirection == "ascending")
                ? Direction.Ascending
                : Direction.Descending
            
            var sortedMediaCollection = sortBy.sort(media: mediaCollection,
                                                    direction: direction)
            
            if let skip = Int(paramSkip) {
                if skip > 0 {
                    sortedMediaCollection.removeFirst(skip)
                }
            }
            
            if let paramLimit = paramLimit {
                if let limit = Int(paramLimit) {
                    if limit > 0 {
                        let quantityToRemove = (sortedMediaCollection.count - limit)
                        if quantityToRemove > 0 {
                            sortedMediaCollection.removeLast(quantityToRemove)
                        }
                    }
                }
            }
            
            var imageData = [[String:Any]]()
            
            for (index, media) in sortedMediaCollection.enumerated() {
                var data = [String:Any]()
                
                data["id"] = media.id.uuidString
                data["index"] = index
                data["name"] = media.filename
                data["title"] = media.filename
                data["alt"] = media.filename
                data["thumbnailUrl"] = "/thumbnail/\(media.id)"
                data["resourceUrl"] = "/image/\(media.id)"
                data["width"] = media.mediaInfo.resolution.width
                data["height"] = media.mediaInfo.resolution.height
                data["fitToAspect"] = true
                
                if media is Video {
                    data["resourceUrl"] = "/video/\(media.id)"
                }
                
                if media is LivePhoto {
                    data["imageUrl"] = "/image/\(media.id)"
                    data["videoUrl"] = "/video/\(media.id)"
                    data["resourceUrl"] = "/livephoto/\(media.id)"
                }
                
                imageData.append(data)
            }
            
            let json: [String:Any] = [
                "totalImages": mediaManager.count,
                "imageData": imageData
            ]
            
            return self.sendJSON(json as AnyObject)
        }
        server["/downloadProgress/:id"] = { (request: HttpRequest) -> HttpResponse in
            print("/downloadProgress/\(request.params[":id"] ?? "")")
            
            if let idParam = request.params[":id"] {
                if let downloadId = UUID(uuidString: idParam) {
                    if let operation = self.zipOperations[downloadId] {
                        var response: [String: Any] = [
                            "downloadId": JSONHelper.ToString(uuid: downloadId),
                            "status": "pending",
                            "percentage": operation.progress * 100
                        ]
                        
                        if operation.progress == 1{
                            response["downloadUrl"] = "/downloads/\(downloadId).zip"
                            response["status"] = "done"
                        }
                        
                        return self.sendJSON(response as AnyObject)
                    }
                }
            }
            
            return .internalServerError
        }
        server["/downloads/:idAndExtension"] = { (request: HttpRequest) -> HttpResponse in
            print("/downloads/\(request.params[":idAndExtension"] ?? "")")

            if let idAndExtensionParam = request.params[":idAndExtension"] {
                let idParam = (idAndExtensionParam as NSString).deletingPathExtension
                if let downloadId = UUID(uuidString: idParam) {
                    if let operation = self.zipOperations[downloadId] {
                        if operation.progress == 1 {
                            return self.serve(filename: operation.zipArchiveURL.path,
                                              autoDelete: true)
                        } else {
                            return .raw(503, "Not available", nil, nil)
                        }
                    }
                }
            }

            return .internalServerError
        }
        server["prepareImagesForDownload"] = { (request: HttpRequest) -> HttpResponse in
            print("/prepareImagesForDownload")

            if let bodyString = String(bytes: request.body,
                                       encoding: .utf8) {
                if let json = JSONHelper.ToJSON(fromString: bodyString) {
                    let zipOperation = ZipOperation()

                    for (key, subJson):(String, JSON) in json {
                        if let id = JSONHelper.ToUUID(string: subJson.stringValue) {
                            print("\(key):\(id)")

                            if let media = mediaManager.getMedia(byId: id) {
                                let fileURLs = media.getFileURLs
                                
                                for fileURL in fileURLs {
                                    zipOperation.add(url: fileURL)
                                }
                            }
                        }
                    }
                    
                    if zipOperation.beginZip() {
                        self.zipOperations[zipOperation.downloadId] = zipOperation
                        
                        let response: [String:Any] = [
                            "downloadId": JSONHelper.ToString(uuid: zipOperation.downloadId)
                        ]
        
                        return self.sendJSON(response as AnyObject)
                    }
                }
            }
            
            return .badRequest(nil)
        }
//        server["isReadyForDownload"] = { (request: HttpRequest) -> HttpResponse in
//
//            return .internalServerError
//        }
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
    
    public func sendJSON(_ json: AnyObject) -> HttpResponse {
        return .ok(.json(json))
    }
    
    public func returnTemplatedFile(_ path: String, templates: [String: String]) -> HttpResponse {
        do {
            var text = try String(contentsOf: URL(fileURLWithPath: path),
                                  encoding: .utf8)
            for (name, replacement) in templates {
                text = text.replacingOccurrences(of: name,
                                                 with: replacement)
            }
            
            return .ok(.text(text))
        }
        catch {
            print("Server error: \(error)")
            return .internalServerError
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
            
            return self.serve(filename: directoryPath + String.pathSeparator + fileRelativePath.value)
        }
    }
    
    func serve(filename: String,
               autoDelete: Bool = false) -> HttpResponse {
        if let file = try? (filename).openForReading() {
            let headers: [String:String]?
            
            switch (filename as NSString).pathExtension.lowercased() {
            case "js": headers = ["Content-type":"application/javascript"]
            case "html": headers = ["Content-type":"text/html"]
            case "json": headers = ["Content-type":"application/json"]
            case "css": headers = ["Content-type":"text/css"]
            case "jpg": headers = ["Content-type":"image/jpeg"]
            case "jpeg": headers = ["Content-type":"image/jpeg"]
            case "png": headers = ["Content-type":"image/png"]
            case "gif": headers = ["Content-type":"image/gif"]
            case "mov": headers = ["Content-type":"video/quicktime"]
            case "mp4": headers = ["Content-type":"video/mp4"]
            case "zip": headers = ["Content-type":"application/zip"]
            default: headers = ["Content-type":"text/plain"]
            }
            
            return .raw(200, "OK", headers, { writer in
                try? writer.write(file)
                file.close()
                if (autoDelete) {
                    try? FileManager.default.removeItem(atPath: filename)
                }
            })
        }
        return .notFound
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
