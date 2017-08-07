//
//  PhotoManager.swift
//  SPV
//
//  Created by dlatheron on 07/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation

class PhotoManager {
    var photos: [String]
    
    init(withPhotos initialPhotos: [String]) {
        photos = initialPhotos
    }
    
    func getPhotoPath(at index: Int) -> String {
        return photos[index]
    }
    
    public var count: Int {
        get {
            return photos.count
        }
    }
}
