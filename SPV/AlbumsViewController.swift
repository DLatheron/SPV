//
//  AlbumsViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit

class AlbumsViewController: UICollectionViewController {
    
    var media: [Media] = []
    
    let mediaManager: MediaManager
    
    // MARK: - Properties
    fileprivate let reuseIdentifier = "PhotoCellId"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
   
    required init(coder aDecoder: NSCoder) {
        mediaManager = MediaManager.shared
        
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mediaManager.delegate = self
        media = mediaManager.media
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
        return MediaManager.shared.count
    }
    
    func getImage(at index: Int) -> UIImage? {
        return UIImage(contentsOfFile: media[index].fileURL.path)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! PhotoCell
        let media = getMedia(for: indexPath)
        
        cell.configure(withMedia: media)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "PhotoDetails") {
            let photoCell = sender as! PhotoCell
            let photoDetailsVC = segue.destination as! PhotoDetailsViewController
            let indexPath = collectionView?.indexPath(for: photoCell)
            let media = getMedia(forIndexPath: indexPath!)
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            photoDetailsVC.media = media
            photoDetailsVC.image = photoCell.imageView.image
            photoDetailsVC.delegate = self
        }
    }
    
    func getMedia(for indexPath: IndexPath) -> Media {
        return media[indexPath.row]
    }
    
    func getIndex(of media: Media) -> Int? {
        return self.media.index(of: media)
    }
    
    func clampIndex(index: Int) -> Int {
        let upperBound = self.media.count - 1
        if index < 0 {
            return upperBound
        } else if index > upperBound {
            return 0
        } else {
            return index
        }
    }
    
    func getIndexPath(of media: Media) -> IndexPath? {
        if let index = getIndex(of: media) {
            return IndexPath(row: index,
                             section: 0)
        } else {
            return nil
        }
    }
    
    func getMedia(forIndexPath indexPath: IndexPath) -> Media {
        return self.media[indexPath.row]
    }
}

extension AlbumsViewController : UICollectionViewDelegateFlowLayout {
    
}

extension AlbumsViewController : MediaManagerChangedProtocol {
    func added(media: Media) {
        DispatchQueue.main.async {
            self.media.append(media)
            self.collectionView?.insertItems(at: [ IndexPath(row: self.media.count - 1,
                                                             section: 0) ])
        }
    }
    
    func changed(media: Media) {
        DispatchQueue.main.async {
            if let index = self.media.index(of: media) {
                self.collectionView?.reloadItems(at: [ IndexPath(row: index,
                                                                 section: 0)])
            }
        }
    }
    
    func deleted(media: Media) {
        DispatchQueue.main.async {
            if let index = self.media.index(of: media) {
                self.media.remove(at: index)
                self.collectionView?.deleteItems(at: [ IndexPath(row: index,
                                                                 section: 0) ])
            }
        }
    }
}

extension AlbumsViewController : MediaEnumerator {
    func nextMedia(media: Media) -> Media {
        let index = getIndex(of: media)!
        return self.media[clampIndex(index: index + 1)]
    }
    
    func prevMedia(media: Media) -> Media {
        let index = getIndex(of: media)!
        return self.media[clampIndex(index: index - 1)]
    }
}
