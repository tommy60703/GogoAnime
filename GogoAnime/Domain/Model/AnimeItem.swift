//
//  AnimeItem.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

struct AnimeItem: Hashable, Codable {
    
    typealias ID = Int
    
    var id: ID
    var urlString: String?
    var imageURLString: String?
    var title: String
    var rank: Int
    var startDate: String?
    var endDate: String?
    var type: String
    
    /// Not an API field
    private var isFavoriteOrNil: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "mal_id"
        case urlString = "url"
        case imageURLString = "image_url"
        case title
        case rank
        case startDate = "start_date"
        case endDate = "end_date"
        case type
        case isFavoriteOrNil
    }
    
    var url: URL? {
        if let urlString = urlString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: urlString)
        }
        return nil
    }
    
    var imageURL: URL? {
        if let imageURLString = imageURLString?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            return URL(string: imageURLString)
        }
        return nil
    }
    
    var isFavorite: Bool {
        set {
            isFavoriteOrNil = newValue
        }
        get {
            isFavoriteOrNil ?? false
        }
    }
}

enum AnimeItemType: String {
    case anime
    case manga
}

enum AnimeItemSubtype: String {
    // for type anime
    case airing, upcoming, tv, movie, ova, special
    
    // for type manga
    case manga, novels, oneshots, doujin, manhwa, manhua
    
    // for both
    case bypopularity, favorite
}
