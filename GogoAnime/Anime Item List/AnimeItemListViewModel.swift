//
//  AnimeItemListViewModel.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Combine
import Foundation

enum ViewModelState {
    case idle
    case loading
    case error(Error)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

final class AnimeItemListViewModel {
    
    @Published private(set) var reloadState: ViewModelState = .idle
    @Published private(set) var loadMoreState: ViewModelState = .idle
    @Published private(set) var animeItems: [AnimeItem]?
    @Published private(set) var currentPage: Int = 1
    
    private var loadMoreTask: Task<(), Never>?
    
    private let useCase: AnimeItemUseCase
    private let type: AnimeItemType
    private let subtype: AnimeItemSubtype?
    
    init(useCase: AnimeItemUseCase, type: AnimeItemType, subtype: AnimeItemSubtype?) {
        self.useCase = useCase
        self.type = type
        self.subtype = subtype
    }
    
    func addToFavorites(_ id: AnimeItem.ID) {
        // TODO: update favorite list repo
        guard var animeItems = animeItems else {
            return
        }

        let index = animeItems.firstIndex { $0.id == id }
        
        if let index = index {
            var item = animeItems[index]
            item.isFavorite = true
            animeItems[index] = item
            
            self.animeItems = animeItems
        }
    }
    
    func removeFromFavorites(_ id: AnimeItem.ID) {
        // TODO: update favorite list repo
        guard var animeItems = animeItems else {
            return
        }
        
        let index = animeItems.firstIndex { $0.id == id }
        
        if let index = index {
            var item = animeItems[index]
            item.isFavorite = false
            animeItems[index] = item
            
            self.animeItems = animeItems
        }
    }
    
    func reload() {
        guard !reloadState.isLoading else {
            return
        }
        
        loadMoreTask?.cancel()
        loadMoreState = .idle
        reloadState = .loading
        
        Task {
            do {
                animeItems = try await useCase.animeItems(type: type, subtype: subtype, page: 1)
                currentPage = 1
                reloadState = .idle
            } catch {
                reloadState = .error(error)
            }
        }
    }
    
    func loadMore() {
        guard !reloadState.isLoading, !loadMoreState.isLoading else {
            return
        }
        
        loadMoreState = .loading
        
        loadMoreTask = Task {
            do {
                let newItems = try await useCase.animeItems(type: type, subtype: subtype, page: currentPage + 1)
                if let animeItems = animeItems {
                    self.animeItems = animeItems + newItems
                } else {
                    self.animeItems = newItems
                }
                currentPage += 1
                loadMoreState = .idle
            } catch {
                loadMoreState = .error(error)
            }
        }
    }
}
