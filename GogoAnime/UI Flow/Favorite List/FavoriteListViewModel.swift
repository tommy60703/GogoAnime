//
//  FavoriteListViewModel.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/7.
//

import Combine
import Foundation

final class FavoriteListViewModel {
    
    @Published private(set) var animeItems: [AnimeItem] = []
    
    private let useCase: AnimeItemUseCase
    
    init(useCase: AnimeItemUseCase) {
        self.useCase = useCase
    }
    
    func load() {
        Task {
            do {
                animeItems = try await useCase.favoriteAnimeItems()
            } catch {
                debugPrint(error)
                animeItems = []
            }
        }
    }
    
    func removeFromFavorites(_ animeItem: AnimeItem) {
        Task {
            do {
                _ = try await useCase.removeFromFavorites(animeItem)
                animeItems.removeAll { $0.id == animeItem.id }
            } catch {
                debugPrint(error)
            }
        }
    }
}
