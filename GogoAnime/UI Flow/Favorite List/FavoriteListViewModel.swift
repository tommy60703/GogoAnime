//
//  FavoriteListViewModel.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/7.
//

import Combine
import Foundation

final class FavoriteListViewModel {
    
    @globalActor actor Actor: GlobalActor {
        static let shared: Actor = Actor()
    }
    
    @Published private(set) var animeItems: [AnimeItem] = []
    
    private let useCase: AnimeItemUseCase
    
    init(useCase: AnimeItemUseCase) {
        self.useCase = useCase
    }
    
    @Actor func load() async {
        do {
            animeItems = try await useCase.favoriteAnimeItems()
        } catch {
            debugPrint(error)
            animeItems = []
        }
    }
    
    @Actor func removeFromFavorites(_ animeItem: AnimeItem) async {
        do {
            _ = try await useCase.removeFromFavorites(animeItem)
            animeItems.removeAll { $0.id == animeItem.id }
        } catch {
            debugPrint(error)
        }
    }
}
