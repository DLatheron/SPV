
//
//  AlbumsViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import MobileCoreServices
import PhotosUI

fileprivate let deleteMediaTitle = NSLocalizedString("Delete Media",
                                                     comment: "Action item title for deleting selected media")
fileprivate let moveMediaTitle = NSLocalizedString("Move To...",
                                                   comment: "Action item title for moving selected media")
fileprivate let shareMediaTitle = NSLocalizedString("Share To...",
                                                    comment: "Action item title for sharing selected media")
fileprivate let cancelTitle = NSLocalizedString("Cancel",
                                                comment: "Action item title for cancelling media seletion")
fileprivate let importPhotoTitle = NSLocalizedString("Import Photo...",
                                                     comment: "Import from photos")

class AlbumsViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var selectButton: UIBarButtonItem!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var sortPanelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sortBySegment: UISegmentedControl!
    @IBOutlet weak var directionSegment: UISegmentedControl!
    
    enum SortBy: Int {
        case Added
        case Created
        case Size
        case Other
    }
    
    enum Direction: Int {
        case Ascending
        case Descending
    }
    
    fileprivate var sortBy: SortBy = .Added
    fileprivate var direction: Direction = .Ascending
    
    fileprivate var deleteButton: UIBarButtonItem!
    fileprivate var actionButton: UIBarButtonItem!
    fileprivate var importButton: UIBarButtonItem!
    fileprivate var sortButton: UIBarButtonItem!
    fileprivate var standardNavButtons: [UIBarButtonItem] = []
    fileprivate var selectedNavButtons: [UIBarButtonItem] = []
    fileprivate var alertController: UIAlertController!
    
    fileprivate var media: [Media] = []
    fileprivate var selectedMedia = Set<Media>() {
        didSet {
            let anyMediaSelected = selectedMedia.count > 0
            deleteButton.isEnabled = anyMediaSelected
            actionButton.isEnabled = anyMediaSelected
            importButton.isEnabled = !anyMediaSelected
            sortButton.isEnabled = !anyMediaSelected
        }
    }
    
    fileprivate let mediaManager: MediaManager
    
    fileprivate let reuseIdentifier = "MediaCellId"
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let sortPanelOpenHeight: CGFloat = 90
    fileprivate let sortPanelClosedHeight: CGFloat = 0
    fileprivate let sortPanelOpenCloseDuration: TimeInterval = 0.3
    
    var selectMode: Bool = false {
        didSet {
            if selectMode {
                selectButton.title = NSLocalizedString("Done",
                                                       comment: "Button title to exit media selection mode")
                navigationItem.setRightBarButtonItems(selectedNavButtons,
                                                      animated: true)
            } else {
                selectButton.title = NSLocalizedString("Select",
                                                       comment: "Button title to enter media selection mode")
                navigationItem.setRightBarButtonItems(standardNavButtons,
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
        selectedNavButtons = [actionButton, deleteButton]
        
        // TODO: Replace with custom import icon.
        importButton = UIBarButtonItem(barButtonSystemItem: .action,
                                       target: self,
                                       action: #selector(importMedia(_:)))
        // TODO: Replace with custom sort icon.
        sortButton = UIBarButtonItem(barButtonSystemItem: .action,
                                     target: self,
                                     action: #selector(sortMedia(_:)))
        standardNavButtons = [importButton, sortButton]
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortPanelHeightConstraint.constant = 0
        
        sortBySegment.addTarget(self,
                                action: #selector(handleSortBy(_:)),
                                for: .valueChanged)
        directionSegment.addTarget(self,
                                   action: #selector(handleDirection(_:)),
                                   for: .valueChanged)
        
        sortMedia(by: self.sortBy,
                  direction: self.direction)

        mediaManager.delegate = self
        media = mediaManager.media
        selectMode = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AlbumsViewController : UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return media.count
    }
    
    func getImage(at index: Int) -> UIImage? {
        return UIImage(contentsOfFile: media[index].fileURL.path)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! MediaCell
        let media = getMedia(for: indexPath)
        let selected = isSelected(media: media)
        
        cell.configure(withMedia: media,
                       isSelected: selected,
                       delegate: self)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "MediaViewer") {
            let mediaCell = sender as! MediaCell
            let photoDetailsVC = segue.destination as! PhotoDetailsViewController
            let indexPath = collectionView?.indexPath(for: mediaCell)
            let media = getMedia(forIndexPath: indexPath!)
            let backItem = UIBarButtonItem()
            backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            photoDetailsVC.media = media
            photoDetailsVC.image = mediaCell.imageView.image
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
        if let index = self.media.index(of: media) {
            self.media.remove(at: index)
            self.collectionView?.deleteItems(at: [ IndexPath(row: index,
                                                             section: 0) ])
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

extension AlbumsViewController : MediaCellDelegate {
    func mediaCellClicked(_ sender: MediaCell) {
        if !selectMode {
            self.performSegue(withIdentifier: "MediaViewer",
                              sender: sender)
        } else {
            sender.isSelected = true
        }
    }
    
    func mediaCellSelectionChanged(_ sender: MediaCell) {
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

extension AlbumsViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true,
                     completion: nil)

        // Is this a photo asset?
        if let asset = info[UIImagePickerControllerPHAsset] as? PHAsset {
            print("Photo asset picked")
            
            print("Asset: \(asset)")
            
            switch asset.mediaSubtypes {
            case .photoLive:
                print("Live Photo")
                
            case .photoPanorama:
                print("Panorama")
                
            case .photoHDR:
                print("HDR Photo")
                
            default:
                print("Other")
            }
        }
        
        // Is this a live photo?
        if let livePhoto = info[UIImagePickerControllerLivePhoto] as? PHLivePhoto {
            print("Live Photo picked")
            
            
            let livePhotoView = PHLivePhotoView(frame: self.view.bounds)
            livePhotoView.livePhoto = livePhoto
        }

//        // if we have a live photo view already, remove it
//        if ([self.view viewWithTag:87]) {
//            UIView *subview = [self.view viewWithTag:87];
//            [subview removeFromSuperview];
//        }
//
//        // check if this is a Live Image, otherwise present a warning
//        PHLivePhoto *photo = [info objectForKey:UIImagePickerControllerLivePhoto];
//        if (!photo) {
//            [self notLivePhotoWarning];
//            return;
//        }
//
//        // create a Live Photo View
//        PHLivePhotoView *photoView = [[PHLivePhotoView alloc]initWithFrame:self.view.bounds];
//        photoView.livePhoto = [info objectForKey:UIImagePickerControllerLivePhoto];
//        photoView.contentMode = UIViewContentModeScaleAspectFit;
//        photoView.tag = 87;
//
//        // bring up the Live Photo View
//        [self.view addSubview:photoView];
//        [self.view sendSubviewToBack:photoView];
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    @objc func importMedia(_ sender: Any) {
        func importFromPhotos() {
            print("TODO: Import from photos")
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.allowsEditing = false;
            picker.delegate = self;
            picker.mediaTypes = [
                kUTTypeMovie as String,
                kUTTypeImage as String,
                kUTTypeLivePhoto as String
            ];
            
            self.present(picker,
                         animated: true,
                         completion: nil)
        }
        
        alertController = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: importPhotoTitle,
                                                style: .default)
        { alertAction in
            importFromPhotos()
            
            self.alertControllerDismissed()
            
            // NOTE: Move operation MUST retain selection (or refresh it).
        })
        alertController.addAction(UIAlertAction(title: cancelTitle,
                                                style: .cancel)
        { alertAction in
            self.alertControllerDismissed()
        })
        present(alertController,
                animated: true)
    }
    
    func animateSortOptions(targetHeight height: CGFloat) {
        sortPanelHeightConstraint.constant = height
        
        UIView.animate(withDuration: sortPanelOpenCloseDuration,
                       delay: 0.0,
                       options: .curveEaseInOut,
                       animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func sortMedia(_ sender: Any) {
        if sortPanelHeightConstraint.constant == sortPanelClosedHeight {
            animateSortOptions(targetHeight: sortPanelOpenHeight)
        } else if sortPanelHeightConstraint.constant == sortPanelOpenHeight {
            animateSortOptions(targetHeight: sortPanelClosedHeight)
        }
    }
    
    @objc func handleSortBy(_ sender: Any) {
        if let sortBy = SortBy(rawValue: sortBySegment.selectedSegmentIndex) {
            self.sortBy = sortBy
            sortMedia(by: self.sortBy,
                      direction: self.direction)
        }
    }
    
    @objc func handleDirection(_ sender: Any) {
        if let direction = Direction(rawValue: directionSegment.selectedSegmentIndex) {
            self.direction = direction
            sortMedia(by: self.sortBy,
                      direction: self.direction)
        }
    }
    
    func sortMedia(by sortBy: SortBy,
                   direction: Direction) {
        // TODO: Perform the sorting...
        
        sortBySegment.selectedSegmentIndex = sortBy.rawValue
        directionSegment.selectedSegmentIndex = direction.rawValue
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
            var indexPaths: [IndexPath] = []
            
            mediaToDelete.forEach { media in
                if let indexPath = getIndexPath(of: media) {
                    indexPaths.append(indexPath)
                }
                mediaManager.deleteMedia(media)
            }
            
            self.alertControllerDismissed(clearSelection: true)
        }
        
        alertController = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: deleteMediaTitle,
                                                style: .destructive)
        { alertAction in
            deleteMedia(self.selectedMedia)
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
