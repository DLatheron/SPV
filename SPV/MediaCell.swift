//
//  MediaCell.swift
//  SPV
//
//  Created by dlatheron on 04/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

protocol MediaCellDelegate {
    func mediaCellClicked(_ sender: MediaCell)
    func mediaCellSelectionChanged(_ sender: MediaCell)
}

class MediaCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var typeIndicatorView: UILabel!
    @IBOutlet weak var dimmingView: UIView!
    
    @IBOutlet weak var typeIndicatorBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var typeIndicatorLeftConstraint: NSLayoutConstraint!
    
    let typeIndicatorOffset = CGSize(width: 2, height: 0)    

    var selectedColour: UIColor = UIColor.blue
    var selectedBorderWidth: CGFloat = 2
    var delegate: MediaCellDelegate? = nil
    var media: Media!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self,
                                                     action: #selector(longPressAction))
        longPress.minimumPressDuration = 0.3
        longPress.cancelsTouchesInView = true
        addGestureRecognizer(longPress)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(tapAction))
        addGestureRecognizer(tap)
        
        imageView.contentMode = .scaleAspectFill
    }
    
    @objc func longPressAction(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            DispatchQueue.main.async {
                self.isSelected = !self.isSelected
                self.delegate?.mediaCellSelectionChanged(self)
            }
        }
    }
    
    @objc func tapAction() {
        DispatchQueue.main.async {
            if self.isSelected {
                self.isSelected = false
                self.delegate?.mediaCellSelectionChanged(self)
            } else {
                self.delegate?.mediaCellClicked(self)
                self.delegate?.mediaCellSelectionChanged(self)
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            selectedView.isHidden = !isSelected
        }
    }
    
    func displayTypeOverlay(mediaExtension: MediaExtension) {
        if let typeIndicatorText = mediaExtension.mediaCellTypeIndicator {
            typeIndicatorView.isHidden = false
            typeIndicatorView.text = typeIndicatorText
        } else {
            typeIndicatorView.isHidden = true
            typeIndicatorView.text = ""
        }
    }
    
    func offsetTypeIndicatorRelativeToImage(imageView: UIImageView) {
        if imageView.contentMode == .scaleAspectFit {
            let result = AVMakeRect(aspectRatio: imageView.image!.size,
                                    insideRect: imageView.frame)
            
            typeIndicatorLeftConstraint.constant = result.minX + typeIndicatorOffset.width
            typeIndicatorBottomConstraint.constant = result.minY + typeIndicatorOffset.height
        }
    }
    
    func configure(withMedia media: Media,
                   isSelected selected: Bool,
                   delegate: MediaCellDelegate?) {
        self.media = media
        self.delegate = delegate
        
        let mediaType = media.mediaExtension.type

        imageView.image = media.getImage()
        isSelected = selected

        displayTypeOverlay(mediaExtension: media.mediaExtension)
        
        backgroundColor = mediaType.mediaCellBackgroundColour
        
        offsetTypeIndicatorRelativeToImage(imageView: imageView)
    }
}
