//
//  FavoriteAnimeItemRepository.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

protocol FavoriteAnimeItemRepository {
    func favoriteAnimeItems() async throws -> [AnimeItem]
    func addToFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem
    func removeFromFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem
}
