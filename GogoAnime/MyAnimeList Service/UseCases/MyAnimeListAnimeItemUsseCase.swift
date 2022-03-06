//
//  MyAnimeListAnimeItemUsseCase.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

class MyAnimeListAnimeItemUseCase: AnimeItemUseCase {
    
    var animeItemRepo: AnimeItemRepository
    
    init(animeItemRepo: AnimeItemRepository) {
        self.animeItemRepo = animeItemRepo
    }
    
    func avilableSubtypes(for type: AnimeItemType) -> [AnimeItemSubtype] {
        switch type {
        case .anime:
            return [.airing, .upcoming, .tv, .movie, .ova, .special, .bypopularity, .favorite]
        case .manga:
            return [.manga, .novels, .oneshots, .doujin, .manhwa, .manhua, .bypopularity, .favorite]
        }
    }
    
    func animeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem] {
        try await animeItemRepo.animeItems(type: type, subtype: subtype, page: page)
    }
}
