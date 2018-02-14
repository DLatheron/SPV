//
//  LivePhoto.swift
//  SPV
//
//  Created by dlatheron on 14/02/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class LivePhoto : Media {
    var imageURL: URL
    var videoURL: URL
    
    init(directoryURL: URL) {
        let dirURLWithoutExtension = directoryURL.deletingPathExtension()
        let filename = dirURLWithoutExtension.lastPathComponent
        
        imageURL = directoryURL.appendingPathComponent("\(filename).jpg")
        videoURL = directoryURL.appendingPathComponent("\(filename).mp4")
        
        super.init(fileURL: directoryURL)
    }
    
    override func getImage() -> UIImage {
        return UIImage(contentsOfFile: imageURL.path)!
    }
}
