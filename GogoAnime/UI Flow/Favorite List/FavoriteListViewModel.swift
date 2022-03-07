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
}
