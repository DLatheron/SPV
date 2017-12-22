//
//  PhotoCell.swift
//  SPV
//
//  Created by dlatheron on 04/08/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell : UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedColour: UIColor = UIColor.blue
    var selectedBorderWidth: CGFloat = 2
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction))
        longPress.minimumPressDuration = 0.3
        longPress.cancelsTouchesInView = true
        addGestureRecognizer(longPress)
    }
    
    @objc func longPressAction(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            DispatchQueue.main.async {
                self.isSelected = !self.isSelected
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                showAsSelected()
            } else {
                showAsUnselected()
            }
        }
    }
    
    func configure(withMedia media: Media) {
        imageView.image = media.getImage()
    }
    
    func showAsSelected() {
        contentView.layer.borderWidth = selectedBorderWidth
        contentView.layer.borderColor = selectedColour.cgColor
        // TODO: Display a tick image view.
    }
    
    func showAsUnselected() {
        contentView.layer.borderWidth = 0
        contentView.layer.borderColor = UIColor.clear.cgColor
        // TODO: Hide the tick image view.
    }
}
