//
//  LocalFavoriteAnimeItemRepository.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

class LocalFavoriteAnimeItemRepository: FavoriteAnimeItemRepository {
    
    private static let faviriteAnimeItemsKey = "favoriteAnimeItems"
    
    func favoriteAnimeItems() async throws -> [AnimeItem] {
        
        guard let data = UserDefaults.standard.data(forKey: Self.faviriteAnimeItemsKey) else {
            return []
        }
        let decoder = JSONDecoder()
        
        guard let animeItems = try? decoder.decode([AnimeItem].self, from: data) else {
            return []
        }
        
        return animeItems.map {
            var item = $0
            item.isFavorite = true
            return item
        }
    }
    
    func addToFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
        var favoriteItems = try await favoriteAnimeItems()
        
        if let found = favoriteItems.first(where: { $0.id == animeItem.id }) {
            return found
        }
        
        var item = animeItem
        item.isFavorite = true
        favoriteItems.append(item)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(favoriteItems)
        
        UserDefaults.standard.set(data, forKey: Self.faviriteAnimeItemsKey)
        
        return item
    }
    
    func removeFromFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
        
        var favoriteItems = try await favoriteAnimeItems()
        
        favoriteItems.removeAll { $0.id == animeItem.id }
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(favoriteItems)
        
        UserDefaults.standard.set(data, forKey: Self.faviriteAnimeItemsKey)
        
        var item = animeItem
        item.isFavorite = false
        
        return item
    }
}
