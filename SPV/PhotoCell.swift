//
//  PhotoCell.swift
//  SPV
//
//  Created by dlatheron on 04/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol PhotoCellDelegate {
    func photoCellClicked(_ sender: PhotoCell)
    func photoCellSelectionChanged(_ sender: PhotoCell)
}

class PhotoCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectedView: UIView!
    @IBOutlet weak var dimmingView: UIView!
    
    var selectedColour: UIColor = UIColor.blue
    var selectedBorderWidth: CGFloat = 2
    var delegate: PhotoCellDelegate? = nil
    var media: Media!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPress.minimumPressDuration = 0.3
        longPress.cancelsTouchesInView = true
        addGestureRecognizer(longPress)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    @objc func longPressAction(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            DispatchQueue.main.async {
                self.isSelected = !self.isSelected
            }
        }
    }
    
    @objc func tapAction() {
        DispatchQueue.main.async {
            if self.isSelected {
                self.isSelected = false
            } else {
                self.delegate?.photoCellClicked(self)
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            selectedView.isHidden = !self.isSelected
            delegate?.photoCellSelectionChanged(self)
        }
    }
    
    func configure(withMedia media: Media,
                   isSelected selected: Bool,
                   delegate: PhotoCellDelegate?) {
        self.media = media
        self.delegate = delegate

        self.imageView.image = media.getImage()        
        self.isSelected = selected
    }
}
