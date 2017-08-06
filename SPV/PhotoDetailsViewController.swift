//
//  PhotoDetailsViewController.swift
//  SPV
//
//  Created by David Latheron on 06/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class PhotoDetailsViewController : UIViewController, UIScrollViewDelegate {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    
    var filePath: String = ""
    var image: UIImage! = nil
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        scrollView.contentSize = imageView.frame.size
        scrollView.delegate = self
    }
    
    //MARK: - UIScrollViewDelegate
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
