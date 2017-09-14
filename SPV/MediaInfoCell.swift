//
//  MediaInfoCell.swift
//  SPV
//
//  Created by dlatheron on 13/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class MediaInfoCell : UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var value: UILabel!
    
    func configure(withTitle title: String, andValue value: String) {
        self.title.text = title
        self.value.text = value
    }
}
