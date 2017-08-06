//
//  AlbumsViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit

class AlbumsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "PhotoCellId"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var albums = ["image001.png", "image002.png", "image003.png", "image004.png"]
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! PhotoCell
        let filePath = photoFilePathForIndexPath(indexPath: indexPath)
        let photo = UIImage(contentsOfFile: filePath)
        cell.filePath = filePath
        cell.imageView.image = photo
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "PhotoDetails") {
            let photoCell = sender as! PhotoCell
            let photoDetailsVC = segue.destination as! PhotoDetailsViewController
            photoDetailsVC.filePath = photoCell.filePath
            photoDetailsVC.image = photoCell.imageView.image
        }
    }
    
    func photoFilePathForIndexPath(indexPath: IndexPath) -> String {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let filename: String
        
        switch indexPath.row {
            case 0: filename = "Test01.jpg"
            case 1: filename = "Test02.jpg"
            case 2: filename = "Test03.jpg"
            case 3: filename = "Test04.png"
            default:
                filename = "Unknown.png"
        }
        
        return documentDirectoryPath.appendingPathComponent(filename)
    }
}

