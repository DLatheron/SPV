//
//  MediaTagCell.swift
//  SPV
//
//  Created by dlatheron on 18/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class MediaTagCell : UITableViewCell {
    
    @IBOutlet weak var tagValue: UILabel!
    
    func configure(withTag tag: String) {
        self.tagValue.text = tag
    }
}
