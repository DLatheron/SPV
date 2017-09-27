//
//  SearchScopeCell.swift
//  SPV
//
//  Created by dlatheron on 27/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

enum SearchScope {
    case all
    case history
    case bookmarks
}

protocol SearchScopeDelegate {
    func changed(scope: SearchScope)
}

class SearchScopeCell : UITableViewCell {
    @IBOutlet weak var scopeButton: UISegmentedControl!

    var delegate: SearchScopeDelegate! = nil
    
    func configure(withInitialScope scope: SearchScope) {
        switch scope {
        case .all: scopeButton.selectedSegmentIndex = 0
        case .history: scopeButton.selectedSegmentIndex = 1
        case .bookmarks: scopeButton.selectedSegmentIndex = 2
        }
        
        scopeButton.addTarget(self,
                              action: #selector(scopeChanged),
                              for: .valueChanged)
    }
    
    @objc func scopeChanged() {
        switch scopeButton.selectedSegmentIndex {
        case 0: delegate?.changed(scope: .all)
        case 1: delegate?.changed(scope: .history)
        case 2: delegate?.changed(scope: .bookmarks)
        default: fatalError("Invalid segment index")
        }
    }
}
