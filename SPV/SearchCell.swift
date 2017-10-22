//
//  SearchCell.swift
//  SPV
//
//  Created by dlatheron on 22/10/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol SearchCellDelegate {
    func tableViewCell(singleTapActionFromCell cell: SearchCell)
    func tableViewCell(doubleTapActionFromCell cell: SearchCell)
}

class SearchCell : UITableViewCell {
    private var tapCounter = 0
    
    var delegate: SearchCellDelegate! = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        addGestureRecognizer(tap)
    }
    
    @objc func tapAction() {
        if tapCounter == 0 {
            DispatchQueue.global(qos: .background).async {
                usleep(250000)
                if self.tapCounter > 1 {
                    self.doubleTapAction()
                } else {
                    self.singleTapAction()
                }
                self.tapCounter = 0
            }
        }
        tapCounter += 1
    }
    
    func singleTapAction() {
        delegate?.tableViewCell(singleTapActionFromCell: self)
    }
    
    func doubleTapAction() {
        delegate?.tableViewCell(doubleTapActionFromCell: self)
    }
}
