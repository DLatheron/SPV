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
    
    func changed(searchText: String?)
    
    func navigateTo(url: String?)
}

class CollapsibleSearchBarViewController : UIViewController {
    let collapseDuration: TimeInterval = 0.3
    let expandDuration: TimeInterval = 0.3
    
    @IBOutlet var searchBar: CollapsibleSearchBar!
    @IBOutlet var progressBar: UIProgressView!
    
    @IBInspectable var collapsedHeight: CGFloat = 64
    @IBInspectable var expandedHeight: CGFloat = 88
    
    var progress: Double = 0 {
        didSet {
            progressBar.progress = Float(progress)
        }
    }
    
    var urlString: String? = "" {
        didSet {
            searchBar.urlString = urlString
        }
    }
    
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
        super.viewDidLoad()

        singleTap = UITapGestureRecognizer(target: self,
                                           action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        view.addGestureRecognizer(singleTap)
        
        searchBar.delegate = self
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
    func expand() {
        interpolant = 0
    }
    
    func collapse() {
        interpolant = 1
    }
    
    func calculateHeight(interpolant: CGFloat) -> CGFloat {
        let clampedInterpolant = min(max(interpolant, 0.0), 1.0)
        
        searchBar.interpolant = clampedInterpolant
        searchBar.isUserInteractionEnabled = clampedInterpolant == 0.0

        let height = Interpolator.interpolate(from: expandedHeight,
                                              to: collapsedHeight,
                                              withProgress: clampedInterpolant)
        
        return height
    }
}

extension CollapsibleSearchBarViewController {
    func activateSearch() {
        searchBar.activate()
        delegate?.activate(searchBarVC: self)
    }
    
    func deactivateSearch() {
        searchBar.deactivate()
        delegate?.deactivate(searchBarVC: self)
    }
}

extension CollapsibleSearchBarViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        delegate?.changed(searchText: searchText)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activateSearch()
        delegate?.changed(searchText: searchBar.text)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        deactivateSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        deactivateSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = self.searchBar.text {
            delegate?.navigateTo(url: searchText)
        }
        
        deactivateSearch()
    }
}
