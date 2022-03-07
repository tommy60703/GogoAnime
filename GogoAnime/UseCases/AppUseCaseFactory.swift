//
//  AppUseCaseFactory.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/7.
//

import Foundation

final class AppUseCaseFactory: UseCaseFactory {
    
    private let animeItemRepo: TopAnimeItemRepository = MyAnimeListAnimeItemRepository()
    private let favoriteAnimeItemRepo: FavoriteAnimeItemRepository = LocalFavoriteAnimeItemRepository()
    
    func makeAnimeItemUseCase() -> AnimeItemUseCase {
        AppAnimeItemUseCase(animeItemRepo: animeItemRepo, favoriteItemRepo: favoriteAnimeItemRepo)
    }
}
