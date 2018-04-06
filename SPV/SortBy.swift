//
//  SortBy.swift
//  SPV
//
//  Created by dlatheron on 03/04/2018.
//  Copyright © 2018 dlatheron. All rights reserved.
//
import Foundation

enum SortBy : Int, EnumCollection {
    case None
    case Name
    case Added
    case Rating
    case Created
    case Size
    
    static func SortFunc(_ fn: @escaping (Media, Media) -> Bool) -> (Media, Media) -> Bool {
        return fn
    }
    
    static let noneAscending = SortFunc { $0.index < $1.index }
    static let noneDescending = SortFunc { !noneAscending($0, $1) }
    static let nameAscending = SortFunc { $0.filename < $1.filename }
    static let nameDescending = SortFunc { !noneAscending($0, $1) }
    static let addedAscending = SortFunc {
        switch ($0.mediaInfo.importDate, $1.mediaInfo.importDate) {
        case (nil, nil):
            return true
        case (nil, _):
            return true
        case (_, nil):
            return false
        case (.some(let a), .some(let b)):
            return a < b
        }
    }
    static let addedDescending = SortFunc { !addedAscending($0, $1) }
    static let createdAscending = SortFunc { $0.mediaInfo.creationDate < $1.mediaInfo.creationDate }
    static let createdDescending = SortFunc { !createdAscending($0, $1) }
    static let fileSizeAscending = SortFunc { $0.mediaInfo.fileSize < $1.mediaInfo.fileSize }
    static let fileSizeDescending = SortFunc { !fileSizeAscending($0, $1) }
    static let ratingAscending = SortFunc { $0.mediaInfo.rating < $1.mediaInfo.rating }
    static let ratingDescending = SortFunc { !ratingAscending($0, $1) }
    
    func sort(media: [Media], direction: Direction) -> [Media] {
        var sortedMedia: [Media]
        
        if direction == .Ascending {
            switch self {
            case .None: sortedMedia = media.sorted(by: SortBy.noneAscending)
            case .Name: sortedMedia = media.sorted(by: SortBy.nameAscending)
            case .Added: sortedMedia = media.sorted(by: SortBy.addedAscending)
            case .Created: sortedMedia = media.sorted(by: SortBy.createdAscending)
            case .Size: sortedMedia = media.sorted(by: SortBy.fileSizeAscending)
            case .Rating: sortedMedia = media.sorted(by: SortBy.ratingAscending)
            }
        } else {
            switch self {
            case .None: sortedMedia = media.sorted(by: SortBy.noneDescending)
            case .Name: sortedMedia = media.sorted(by: SortBy.nameDescending)
            case .Added: sortedMedia = media.sorted(by: SortBy.addedDescending)
            case .Created: sortedMedia = media.sorted(by: SortBy.createdDescending)
            case .Size: sortedMedia = media.sorted(by: SortBy.fileSizeDescending)
            case .Rating: sortedMedia = media.sorted(by: SortBy.ratingDescending)
            }
        }
        
        return sortedMedia
    }
    
    var localizedString: String  {
        get {
            switch self {
            case .None :
                return NSLocalizedString("None",
                                         comment: "Sort by nothing")
            case .Name :
                return NSLocalizedString("Name",
                                         comment: "Sort by name")
            case .Added:
                return NSLocalizedString("Added",
                                         comment: "Sort by date added")
            case .Rating:
                return NSLocalizedString("Rating",
                                         comment: "Sort by rating")
            case .Created:
                return NSLocalizedString("Created",
                                         comment: "Sort by date created")
            case .Size:
                return NSLocalizedString("Size",
                                         comment: "Sort by file size")
            }
        }
    }
}
