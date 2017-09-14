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
    
//    struct InfoMapping {
//        var title: String
//        var formatValue: (Media) -> String
//        
//        init(title: String,
//             formatValue: @escaping (Media) -> String) {
//            self.title = title
//            self.formatValue = formatValue
//        }
//    }
    
    
    typealias ValueFormatter = (Media) -> String
    
    let infoMapping: [(title: String, formatValue: ValueFormatter)] = [
        ("Created", { media in
            return DateFormatter().string(from: media.mediaInfo.creationDate)
        }),
        ("Imported", { media in
            return DateFormatter().string(from: media.mediaInfo.importDate)
        }),
        ("Downloaded", { media in
            return DateFormatter().string(from: media.mediaInfo.dateDownloaded)
        }),
//        ("Last View", { media in
//            return DateFormatter().string(from: media.mediaInfo.lastViewed)
//        }),
        ("Views", { media in
            return "\(media.mediaInfo.previousViews)"
        }),
        ("File Size", { media in
            return HumanReadable.bytes(bytes: media.mediaInfo.fileSize,
                                       units: .bytes,
                                       space: true)
        }),
//        ("Width", { media in
//            return NumberFormatter().string(from: NSNumber(media.mediaInfo.resolution.width))
//        }),
//        ("Height", { media in
//            return NumberFormatter().string(from: media.mediaInfo.resolution.height)
//        }),
    ]
    
    var media: Media? = nil
//    let infoMapping = [
//        InfoMapping(title: "Downloaded") { media in
//            return DateFormatter().string(from: media.mediaInfo.dateDownloaded)
//        },
//        InfoMapping(title: "File Size") { media in
//            return HumanReadable.bytes(bytes: media.mediaInfo.fileSize,
//                                       units: .bytes,
//                                       space: true)
//        },
//    ]

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //infoTableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 44, right: 0)
        infoTableView.allowsSelection = false
        infoTableView.sectionIndexMinimumDisplayRowCount = 99
        
    }
    
    @IBAction func returnToPhotoViewController(_ sender: Any) {
        performSegue(withIdentifier: "unwindSegueToPhotoViewController",
                     sender: self)
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
        
        return headerCell
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Info",
                                                    for: indexPath) as!MediaInfoCell
        let row = indexPath.row
        let mapping = infoMapping[row]
        let title = mapping.title
        let value = infoMapping[row].formatValue(media!);
        
        cell.configure(withTitle: title,
                       andValue: value)
        
        return cell
    }
}
