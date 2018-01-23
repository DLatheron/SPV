//
//  Video.swift
//  SPV
//
//  Created by dlatheron on 05/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Video : Media {
    override func getImage() -> UIImage {
        return generateThumbnail(url: fileURL)
    }
    
    func generateThumbnail(url: URL) -> UIImage {
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imageGenerator.copyCGImage(at: kCMTimeZero, actualTime: nil)
            
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            
            return UIImage()
        }
    }
}
