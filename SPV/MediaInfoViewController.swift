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
    
    let infoMapping: [(title: String, formatValue: ValueFormatter?)] = [
        ("Creation", nil),
        ("Source", { media in
            return media.mediaInfo.source
        }),
        ("Created", { media in
            return ThisClass.FormatDate(date: media.mediaInfo.creationDate)
        }),
        ("Imported", { media in
            return ThisClass.FormatDate(date: media.mediaInfo.importDate)
        }),
        ("Downloaded", { media in
            return ThisClass.FormatDate(date: media.mediaInfo.dateDownloaded)
        }),
        
        ("Sizes", nil),
        ("File Size", { media in
            return ThisClass.FormatBytes(bytes: media.mediaInfo.fileSize)
        }),
        
        ("Resolution", { media in
            return ThisClass.FormatMediaSize(mediaSize: media.mediaInfo.resolution)
        }),
        
        ("View", nil),
        ("Last View", { media in
            return ThisClass.FormatDate(date: media.mediaInfo.lastViewed,
                                        noDateString: "Never")
        }),
        ("Views", { media in
            return ThisClass.FormatNumber(int: media.mediaInfo.previousViews)
        }),
        ("Tags", nil)
    ]
    
    var media: Media? = nil

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return 160
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

extension MediaInfoViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return [ "Section" ]
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return infoMapping.count;
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "Header") as! MediaInfoHeaderCell
        
        headerCell.configure(withMedia: media!)
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let mapping = infoMapping[row]
        let title = mapping.title
        
        if let formatValue = infoMapping[row].formatValue {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Info",
                                                     for: indexPath) as!MediaInfoCell
            let value = formatValue(media!);
            cell.configure(withTitle: title,
                           andValue: value)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubHeading", for: indexPath) as! MediaInfoSubHeadingCell
            cell.configure(withTitle: title)            
            return cell
        }
    }
}
