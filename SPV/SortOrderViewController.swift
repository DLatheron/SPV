//
//  SortOrderViewController.swift
//  SPV
//
//  Created by dlatheron on 05/02/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//

import Foundation
import UIKit

protocol SortViewControllerDelegate: class {
    func sortBy(option: SortBy)
}

@objc enum SortBy: Int {
    case DateAdded = 0
    case DateCreated
    case Size
    
    init?(index: Int) {
        switch index {
        case 0: self = .DateAdded
        case 1: self = .DateCreated
        case 2: self = .Size
        default:
            return nil
        }
    }
    
    static var options: Int {
        get {
            return self.Size.rawValue + 1
        }
    }
    
    var description: String? {
        get {
            switch self {
            case .DateAdded: return "Date Added"
            case .DateCreated: return "Date Created"
            case .Size: return "Size"
            }
        }
    }
}

class SortOrderViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate var selectedIndexPath: IndexPath?
    
    weak var delegate: SortViewControllerDelegate?
    
    @IBOutlet var tableView: UITableView!
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return SortBy.options
    }
    
    internal func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortCell",
                                                 for: indexPath as IndexPath)
        cell.selectionStyle = .none
        
        if let sortOption = SortBy(index: indexPath.row) {
            cell.textLabel?.text = sortOption.description
            if sortOption == SortBy.DateAdded {
                cell.accessoryType = .checkmark
                selectedIndexPath = indexPath
            }
        }
        
        return cell
    }
    
    internal func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
        if let sortOption = SortBy(index: indexPath.row) {
            delegate?.sortBy(option: sortOption)
        }
        
        if let path = selectedIndexPath {
            let cell = tableView.cellForRow(at: path)
            cell?.accessoryType = .none
        }
        
        DispatchQueue.main.async {
            self.dismiss(animated: true,
                         completion: nil)
        }
    }
}
