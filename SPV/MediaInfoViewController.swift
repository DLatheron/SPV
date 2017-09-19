//
//  MediaInfoViewController.swift
//  SPV
//
//  Created by dlatheron on 12/09/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import Foundation
import UIKit

class MediaInfoViewController : UIViewController {
    @IBOutlet weak var infoTableView: UITableView!
    
    typealias ValueFormatter = (Media) -> String
    typealias ThisClass = MediaInfoViewController
    
    enum CellType {
        case SubHeader
        case Metadata
    }
    
    var infoMapping: [(type: CellType, title: String, formatValue: ValueFormatter?)] = [
        (.SubHeader, "Creation", nil),
        (.Metadata, "Source", { media in
            return media.mediaInfo.source
        }),
        (.Metadata, "Created", { media in
            return ThisClass.FormatDate(date: media.mediaInfo.creationDate)
        }),
        (.Metadata, "Imported", { media in
            return ThisClass.FormatDate(date: media.mediaInfo.importDate)
        }),
        (.Metadata, "Downloaded", { media in
            return ThisClass.FormatDate(date: media.mediaInfo.dateDownloaded)
        }),
        
        (.SubHeader, "Sizes", nil),
        (.Metadata, "File Size", { media in
            return ThisClass.FormatBytes(bytes: media.mediaInfo.fileSize)
        }),
        
        (.Metadata, "Resolution", { media in
            return ThisClass.FormatMediaSize(mediaSize: media.mediaInfo.resolution)
        }),
        
        (.SubHeader, "View", nil),
        (.Metadata, "Last View", { media in
            return ThisClass.FormatDate(date: media.mediaInfo.lastViewed,
                                        noDateString: "Never")
        }),
        (.Metadata, "Views", { media in
            return ThisClass.FormatNumber(int: media.mediaInfo.previousViews)
        })
    ]
    
    var media: Media? = nil

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = media?.filename
        infoTableView.allowsSelection = false
        infoTableView.sectionIndexMinimumDisplayRowCount = 99
    }
    
    @IBAction func returnToPhotoViewController(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToPhotoViewController",
                     sender: self)
    }
}

extension MediaInfoViewController {
    class func FormatNumber(int number: Int) -> String {
        let numberFormatter = NumberFormatter()
        
        return numberFormatter.string(from: NSNumber(value: number)) ?? "-"
    }
    
    class func FormatNumber(int64 number: Int64) -> String {
        let numberFormatter = NumberFormatter()
        
        return numberFormatter.string(from: NSNumber(value: number)) ?? "-"
    }

    class func FormatDate(date: Date?,
                          noDateString: String = "-") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        if let date = date {
            return dateFormatter.string(from: date)
        } else {
            return noDateString
        }
    }
    
    class func FormatBytes(bytes: Int64) -> String {
        return HumanReadable.bytes(bytes: bytes,
                                   units: .bytes,
                                   space: true)
    }
    
    class func FormatMediaSize(mediaSize: MediaInfo.MediaSize) -> String {
        let numberFormatter = NumberFormatter()
        let width = numberFormatter.string(from: NSNumber(value: mediaSize.width)) ?? "-"
        let height = numberFormatter.string(from: NSNumber(value: mediaSize.height)) ?? "-"
        
        return "\(width) x \(height)"
    }
}

extension MediaInfoViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        if (section == 0) {
            return 160
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension MediaInfoViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return [ "Section", "Tags" ]
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return infoMapping.count;
        } else {
            let tagCount = media?.mediaInfo.tags.count ?? 0
            return tagCount + 1
        }
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerCell = tableView.dequeueReusableCell(withIdentifier: "Header") as! MediaInfoHeaderCell
            
            headerCell.configure(withMedia: media!)
            
            return headerCell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubHeading") as! MediaInfoSubHeadingCell
            cell.configure(withTitle: "Tags")
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let mapping = infoMapping[row]
        let title = mapping.title
        
        if indexPath.section == 0 {
            switch infoMapping[row].type {
            case .SubHeader:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SubHeading", for: indexPath) as! MediaInfoSubHeadingCell
                cell.configure(withTitle: title)
                return cell
                
            case .Metadata:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Info",
                                                         for: indexPath) as!MediaInfoCell
                if let formatValue = infoMapping[row].formatValue {
                    let value = formatValue(media!);
                    cell.configure(withTitle: title,
                                   andValue: value)
                }
                
                return cell
            }
        } else {
            let tagCount = media!.mediaInfo.tags.count
            
            if indexPath.row == tagCount {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddTag",
                                                         for: indexPath) as! MediaAddTagCell
                
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Tag",
                                                         for: indexPath) as! MediaTagCell
                let tag = media!.mediaInfo.tags[indexPath.row];
            
                cell.configure(withTag: tag)
            
                return cell
            }
        }
    }
}
