
//
//  AlbumsViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit

fileprivate let deleteMediaTitle = NSLocalizedString("Delete Media",
                                                     comment: "Action item title for deleting selected media")
fileprivate let moveMediaTitle = NSLocalizedString("Move To...",
                                                   comment: "Action item title for moving selected media")
fileprivate let shareMediaTitle = NSLocalizedString("Share To...",
                                                    comment: "Action item title for sharing selected media")
fileprivate let cancelTitle = NSLocalizedString("Cancel",
                                                comment: "Action item title for cancelling media seletion")

class AlbumsViewController: UICollectionViewController {
    @IBOutlet weak var selectButton: UIBarButtonItem!
    
    fileprivate var deleteButton: UIBarButtonItem!
    fileprivate var actionButton: UIBarButtonItem!
    fileprivate var navButtons: [UIBarButtonItem] = []
    fileprivate var alertController: UIAlertController!
    
    fileprivate var media: [Media] = []
    fileprivate var selectedMedia = Set<Media>() {
        didSet {
            let anyMediaSelected = selectedMedia.count > 0
            deleteButton.isEnabled = anyMediaSelected
            actionButton.isEnabled = anyMediaSelected
        }
    }
    
    fileprivate let mediaManager: MediaManager
    
    fileprivate let reuseIdentifier = "PhotoCellId"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    var selectMode: Bool = false {
        didSet {
            if selectMode {
                selectButton.title = NSLocalizedString("Done",
                                                       comment: "Button title to exit media selection mode")
                navigationItem.setRightBarButtonItems(navButtons,
                                                      animated: true)
            } else {
                selectButton.title = NSLocalizedString("Select",
                                                       comment: "Button title to enter media selection mode")
                navigationItem.setRightBarButtonItems([],
                                                      animated: true)
                deselectAll()
            }
        }
    }
   
    required init(coder aDecoder: NSCoder) {
        mediaManager = MediaManager.shared
        
        super.init(coder: aDecoder)!
    }
    
    override func awakeFromNib() {
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash,
                                       target: self,
                                       action: #selector(deleteSelectedMedia(_:)))
        actionButton = UIBarButtonItem(barButtonSystemItem: .action,
                                       target: self,
                                       action: #selector(actionOnSelectedMedia(_:)))
        navButtons = [actionButton, deleteButton]
        
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
        let selected = isSelected(media: media)
        
        cell.configure(withMedia: media,
                       isSelected: selected,
                       delegate: self)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "MediaViewer") {
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

extension AlbumsViewController {
    func deselectAll() {
        selectedMedia.removeAll()
        self.collectionView?.reloadData()
    }
    
    func isSelected(media: Media) -> Bool {
        return selectedMedia.contains(media)
    }
    
    @IBAction func selectButtonClicked(_ sender: Any) {
        if !selectMode {
            selectMode = true
            selectButton.title = NSLocalizedString("Done", comment: "Button title to exit media selection mode")
        } else {
            selectMode = false
            selectButton.title = NSLocalizedString("Select", comment: "Button title to enter media selection mode")
            
            deselectAll()
        }
    }
}

extension AlbumsViewController : PhotoCellDelegate {
    func photoCellClicked(_ sender: PhotoCell) {
        if !selectMode {
            self.performSegue(withIdentifier: "MediaViewer",
                              sender: sender)
        } else {
            sender.isSelected = true
        }
    }
    
    func photoCellSelectionChanged(_ sender: PhotoCell) {
        if let media = sender.media {
            if sender.isSelected {
                selectedMedia.insert(media)
                selectMode = true
            } else {
                selectedMedia.remove(media)
            }
        }
    }
}

extension AlbumsViewController {
    fileprivate func alertControllerDismissed(clearSelection: Bool = false) {
        self.alertController = nil
        if clearSelection {
            self.selectMode = false
        }
    }
    
    @objc func deleteSelectedMedia(_ sender: Any) {
        func deleteMedia(_ mediaToDelete: Set<Media>) {
            print("TODO: Delete: \(mediaToDelete)")
        }
        
        alertController = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: deleteMediaTitle,
                                                style: .destructive)
        { alertAction in
            deleteMedia(self.selectedMedia)
            
            self.alertControllerDismissed(clearSelection: true)
        })
        alertController.addAction(UIAlertAction(title: cancelTitle,
                                                style: .cancel)
        { alertAction in
             self.alertControllerDismissed()
        })
        present(alertController,
                animated: true)
    }
    
    @objc func actionOnSelectedMedia(_ sender: Any) {
        func moveMedia(_ mediaToMove: Set<Media>) {
            print("TODO: Move: \(mediaToMove)")
        }
        
        func shareMedia(_ mediaToShare: Set<Media>) {
            print("TODO: Share: \(mediaToShare)")
        }
        
        alertController = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: moveMediaTitle,
                                                style: .default)
        { alertAction in
            moveMedia(self.selectedMedia)
            
            self.alertControllerDismissed()
            
            // NOTE: Move operation MUST retain selection (or refresh it).
        })
        alertController.addAction(UIAlertAction(title: shareMediaTitle,
                                                style: .default)
        { alertAction in
            shareMedia(self.selectedMedia)
            
            self.alertControllerDismissed()
        })
        alertController.addAction(UIAlertAction(title: cancelTitle,
                                                style: .cancel)
        { alertAction in
            self.alertControllerDismissed()
        })
        present(alertController,
                animated: true)
        
        // EXPORT?
    }
}
