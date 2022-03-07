//
//  AnimeItemUseCase.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

protocol AnimeItemUseCase {
    var animeItemRepo: AnimeItemRepository { get }
    
    func availableTypes() -> [AnimeItemType]
    func availableSubtypes(for type: AnimeItemType) -> [AnimeItemSubtype]
    func animeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem]
    
    func favoriteAnimeItems() async throws -> [AnimeItem]
    func addToFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem
    func removeFromFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem
}
