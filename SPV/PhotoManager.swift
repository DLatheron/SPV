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
    var basePath: NSString
    var photos: [String]
    
    init(withPhotos initialPhotos: [String]) {
        photos = initialPhotos
        basePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
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
}
