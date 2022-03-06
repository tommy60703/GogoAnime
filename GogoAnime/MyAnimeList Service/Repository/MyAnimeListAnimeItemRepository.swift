//
//  MyAnimeListAnimeItemRepository.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

class MyAnimeListAnimeItemRepository: AnimeItemRepository {
    
    func animeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem] {
        
        struct ResponseModel: Decodable {
            var top: [AnimeItem]
        }
        
        let endpoint = MyAnimeListEndpoint.topAnimeList(type: type, subtype: subtype, page: page)
        
        let (data, _) = try await URLSession.shared.data(for: endpoint.request, delegate: nil)
        
        // TODO: - check response status code
        
        let decoder = JSONDecoder()
        let responseModel = try decoder.decode(ResponseModel.self, from: data)
        
        return responseModel.top
    }
}

enum MyAnimeListEndpoint {
    case topAnimeList(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int)
}

extension MyAnimeListEndpoint: Endpoint {
    
    var baseURL: URL {
        URL(string: "https://api.jikan.moe/v3/top/")!
    }
    
    var path: String {
        switch self {
        case let .topAnimeList(type, subtype, page):
            var path = "\(type.rawValue)/\(page)"
            if let subtype = subtype {
                path += "/\(subtype)"
            }
            return path
        }
    }
    
    var httpMethod: HTTPMethod { .get }
    
    var parameters: [String : Any]? { nil }
}
