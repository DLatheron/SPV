//
//  PhotoManager.swift
//  SPV
//
//  Created by dlatheron on 07/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class PhotoManager {
    let extensions = [
        "jpg",
        "jpeg",
        "png",
        "bmp",
        "gif"
    ]
    var basePath: NSString
    var photos: [String]
    
    init(withPhotos initialPhotos: [String]) {
        basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        photos = initialPhotos
    }
    
    init(fromDirectory rootDirectory: String) {
        basePath = rootDirectory as NSString
        photos = []
        photos = extractAllFiles(atPath: basePath as String, withExtensions: extensions)
    }
    
    // TODO: 
    // - Proper photo class underneath this manager;
    //   - Name and other metadata (populated on-demand???);
    // - Caching of images;
    // - Caching of photo paths (if necessary?);
    
    func getPhotoName(at index: Int) -> String {
        return photos[index]
    }
    
    func getPhotoPath(at index: Int) -> String {
        return basePath.appendingPathComponent(photos[index])
    }
    
    func getPhotoImage(at index: Int) -> UIImage? {
        return UIImage(contentsOfFile: getPhotoPath(at: index))
    }
    
    public var count: Int {
        get {
            return photos.count
        }
    }
    
    // Based on: https://stackoverflow.com/a/41979088/1176581
    private func extractAllFiles(atPath path: String,
                                 withExtensions fileExtensions: [String]) -> [String] {
        let pathURL = NSURL(fileURLWithPath: path,
                            isDirectory: true)
        var allFiles: [String] = []
        let fileManager = FileManager.default
        let pathString = path.replacingOccurrences(of: "file:", with: "")
        if let enumerator = fileManager.enumerator(atPath: pathString) {
            for file in enumerator {
                if let path = NSURL(fileURLWithPath: file as! String,
                                    relativeTo: pathURL as URL).path {
                    let fileExt = (path as NSString).pathExtension
                    
                    if fileExtensions.contains(fileExt) {
                        let filename = (path as NSString).lastPathComponent
                        allFiles.append(filename)
                    }
                }
            }
        }
        return allFiles
    }
}
