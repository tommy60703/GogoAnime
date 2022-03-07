//
//  AppAnimeItemUsseCase.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

class AppAnimeItemUseCase: AnimeItemUseCase {
    
    var animeItemRepo: TopAnimeItemRepository
    var favoriteItemRepo: FavoriteAnimeItemRepository
    
    init(animeItemRepo: TopAnimeItemRepository, favoriteItemRepo: FavoriteAnimeItemRepository) {
        self.animeItemRepo = animeItemRepo
        self.favoriteItemRepo = favoriteItemRepo
    }
    
    func availableTypes() -> [AnimeItemType] {
        return [.anime, .manga]
    }
    
    func availableSubtypes(for type: AnimeItemType) -> [AnimeItemSubtype] {
        switch type {
        case .anime:
            return [.airing, .upcoming, .tv, .movie, .ova, .special, .bypopularity, .favorite]
        case .manga:
            return [.manga, .novels, .oneshots, .doujin, .manhwa, .manhua, .bypopularity, .favorite]
        }
    }
    
    func topAnimeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem] {
        var animeItems = try await animeItemRepo.topAnimeItems(type: type, subtype: subtype, page: page)
        let favoriteIDs = try await favoriteItemRepo.favoriteAnimeItems().map(\.id)
        
        for (index, var animeItem) in animeItems.enumerated() where favoriteIDs.contains(animeItem.id) {
            animeItem.isFavorite = true
            animeItems[index] = animeItem
        }
        return animeItems
    }
    
    func favoriteAnimeItems() async throws -> [AnimeItem] {
        try await favoriteItemRepo.favoriteAnimeItems()
    }
    
    func addToFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
        try await favoriteItemRepo.addToFavorites(animeItem)
    }
    
    func removeFromFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
        try await favoriteItemRepo.removeFromFavorites(animeItem)
    }
}
