//
//  PhotoGIF.swift
//  SPV
//
//  Created by dlatheron on 17/01/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class PhotoGIF : Media {
    override func getImage() -> UIImage {
        let properFileURL = URL(fileURLWithPath: fileURL.absoluteString)
        let data = try? Data(contentsOf: properFileURL)
        let baseGif = UIImage.gifImageWithData(data!)
        return baseGif!
    }
}
