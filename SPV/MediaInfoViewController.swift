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
            return ThisClass.FormatDate(date: media.mediaInfo.lastViewed)
        }),
        ("Views", { media in
            return ThisClass.FormatNumber(int: media.mediaInfo.previousViews)
        }),
        
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

    class func FormatDate(date: Date?) -> String {
        let dateFormatter = DateFormatter()
        
        if let date = date {
            return dateFormatter.string(from: date)
        } else {
            return "-"
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
        return 144
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
        
//        let blurEffect = UIBlurEffect(style: .dark)
//        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
//        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
//        vibrancyEffectView.frame = CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40)
//        vibrancyEffectView.autoresizingMask = .flexibleWidth
//        
//        //Create header label
//        let vibrantLabel = UILabel()
//        vibrantLabel.frame = vibrancyEffectView.frame
//        vibrantLabel.autoresizingMask = .flexibleWidth
//        vibrantLabel.text = "testing"
//        vibrantLabel.font = UIFont.systemFont(ofSize: 16)
//        vibrantLabel.textColor = UIColor(white: 0.64, alpha: 1)
//        
//        vibrancyEffectView.contentView.addSubview(vibrantLabel)
//        return vibrancyEffectView
        
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
