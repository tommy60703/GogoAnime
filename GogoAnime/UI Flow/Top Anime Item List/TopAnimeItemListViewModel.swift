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

final class TopAnimeItemListViewModel {
    
    @Published private(set) var reloadState: ViewModelState = .idle
    @Published private(set) var loadMoreState: ViewModelState = .idle
    @Published private(set) var animeItems: [AnimeItem]?
    @Published private(set) var currentPage: Int = 1
    
    let animeItemDidUpdate = PassthroughSubject<AnimeItem.ID, Never>()
    
    private var loadMoreTask: Task<(), Never>?
    
    private let useCase: AnimeItemUseCase
    private let type: AnimeItemType
    private let subtype: AnimeItemSubtype?
    
    init(useCase: AnimeItemUseCase, type: AnimeItemType, subtype: AnimeItemSubtype?) {
        self.useCase = useCase
        self.type = type
        self.subtype = subtype
    }
    
    func addToFavorites(_ animeItem: AnimeItem) {
        Task {
            do {
                let updated = try await useCase.addToFavorites(animeItem)
                
                let index = animeItems?.firstIndex { $0.id == animeItem.id }
                
                if let index = index {
                    animeItems?[index] = updated
                    animeItemDidUpdate.send(animeItem.id)
                }
            } catch {
                debugPrint(error)
            }
        }
    }
    
    func removeFromFavorites(_ animeItem: AnimeItem) {
        Task {
            do {
                let updated = try await useCase.removeFromFavorites(animeItem)
                
                let index = animeItems?.firstIndex { $0.id == animeItem.id }
                
                if let index = index {
                    animeItems?[index] = updated
                    animeItemDidUpdate.send(animeItem.id)
                }
            } catch {
                debugPrint(error)
            }
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
                animeItems = try await useCase.topAnimeItems(type: type, subtype: subtype, page: 1)
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
                let newItems = try await useCase.topAnimeItems(type: type, subtype: subtype, page: currentPage + 1)
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
