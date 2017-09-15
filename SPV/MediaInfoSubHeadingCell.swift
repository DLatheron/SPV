//
//  MediaInfoSubHeadingCell.swift
//  SPV
//
//  Created by dlatheron on 15/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class MediaInfoSubHeadingCell : UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    func configure(withTitle title: String) {
        titleLabel.text = title
    }
}
