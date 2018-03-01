//
//  CollapsibleSearchBarViewController.swift
//  SPV
//
//  Created by dlatheron on 26/02/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol CollapsibleSearchBarDelegate {
    func expand(searchBarVC: CollapsibleSearchBarViewController,
               whenExpanded: (() -> ())?) -> Bool
    func collapse(searchBarVC: CollapsibleSearchBarViewController,
                whenCollapsed: (() -> ())?) -> Bool
    
    func activate(searchBarVC: CollapsibleSearchBarViewController)
    func deactivate(searchBarVC: CollapsibleSearchBarViewController)
}

class CollapsibleSearchBarViewController : UIViewController {
    let collapseDuration: TimeInterval = 0.3
    let expandDuration: TimeInterval = 0.3
    
    @IBOutlet var searchBar: CollapsibleSearchBar!
    @IBOutlet var progressBar: UIProgressView!
    
    @IBInspectable var collapsedHeight: CGFloat = 64
    @IBInspectable var expandedHeight: CGFloat = 88
    
    private var _interpolant: CGFloat = 0
    @IBInspectable var interpolant: CGFloat {
        get {
            return _interpolant
        }
        set {
            _interpolant = max(min(newValue, 1), 0)
        }
    }
    var singleTap: UITapGestureRecognizer!
    var delegate: CollapsibleSearchBarDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        singleTap = UITapGestureRecognizer(target: self,
                                           action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
    }
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        print("Single Tap")
        
        if self.view.bounds.height != expandedHeight {
            _ = delegate?.expand(searchBarVC: self) {
                self.activateSearch()
            }
        } else {
            activateSearch()
        }
    }
}

extension CollapsibleSearchBarViewController {
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        print("CollapsibleSearchBarViewController:viewWillLayoutSubviews called")
    }
}

extension CollapsibleSearchBarViewController {
    func expand() {
        interpolant = 0
    }
    
    func collapse() {
        interpolant = 1
    }
    
    func calculateHeight(interpolant: CGFloat) -> CGFloat {
        searchBar.interpolant = interpolant
        searchBar.isUserInteractionEnabled = interpolant == 0.0

        let height = Interpolator.interpolate(from: expandedHeight,
                                              to: collapsedHeight,
                                              withProgress: interpolant)
        
        return height
    }
}

extension CollapsibleSearchBarViewController {
    func activateSearch() {
        delegate?.activate(searchBarVC: self)
    }
    
    func deactivateSearch() {
        delegate?.deactivate(searchBarVC: self)
    }
}
