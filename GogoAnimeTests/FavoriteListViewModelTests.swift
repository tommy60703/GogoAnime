//
//  FavoriteListViewModelTests.swift
//  GogoAnimeTests
//
//  Created by Tommy Lin on 2022/3/9.
//

@testable import GogoAnime
import XCTest

class FavoriteListViewModelTests: XCTestCase {
    
    private var useCase: MockkUseCase!
    private var viewModel: FavoriteListViewModel!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        useCase = MockkUseCase()
        viewModel = FavoriteListViewModel(useCase: useCase)
    }
    
    func test_load_didLoad() async {
        
        // Arrange
        let item1 = AnimeItem(id: 1, urlString: nil, imageURLString: nil, title: "1", rank: 1, startDate: nil, endDate: nil, type: "1", isFavoriteOrNil: true)
        let item2 = AnimeItem(id: 2, urlString: nil, imageURLString: nil, title: "2", rank: 2, startDate: nil, endDate: nil, type: "2", isFavoriteOrNil: true)
       
        useCase.favoriteAnimeItems = [item1, item2]
        
        // Action
        await viewModel.load()
        
        // Assert
        XCTAssertEqual(viewModel.animeItems, [item1, item2])
    }
    
    func test_removeFromFavorites_didRemoveFromFavorites() async {
        
        // Arrange
        let item1 = AnimeItem(id: 1, urlString: nil, imageURLString: nil, title: "1", rank: 1, startDate: nil, endDate: nil, type: "1", isFavoriteOrNil: true)
        let item2 = AnimeItem(id: 2, urlString: nil, imageURLString: nil, title: "2", rank: 2, startDate: nil, endDate: nil, type: "2", isFavoriteOrNil: true)
        
        useCase.favoriteAnimeItems = [item1, item2]
        
        // Action
        await viewModel.load()
        await viewModel.removeFromFavorites(item1)
        
        // Assert
        XCTAssertEqual(viewModel.animeItems, [item2])
    }
    
    func test_removeNonexistsFromFavorites_didNotRemoveFromFavorites() async {
        
        // Arrange
        let item1 = AnimeItem(id: 1, urlString: nil, imageURLString: nil, title: "1", rank: 1, startDate: nil, endDate: nil, type: "1", isFavoriteOrNil: true)
        let item2 = AnimeItem(id: 2, urlString: nil, imageURLString: nil, title: "2", rank: 2, startDate: nil, endDate: nil, type: "2", isFavoriteOrNil: true)
        let item3 = AnimeItem(id: 3, urlString: nil, imageURLString: nil, title: "3", rank: 3, startDate: nil, endDate: nil, type: "3", isFavoriteOrNil: true)
        
        useCase.favoriteAnimeItems = [item1, item2]
        
        // Action
        await viewModel.load()
        await viewModel.removeFromFavorites(item3)
        
        // Assert
        XCTAssertEqual(viewModel.animeItems, [item1, item2])
    }
}

extension FavoriteListViewModelTests {
    
    private class MockkUseCase: AnimeItemUseCase {
        
        var favoriteAnimeItems: [AnimeItem] = []
        
        func availableTypes() -> [AnimeItemType] {
            [.anime, .manga]
        }
        
        func availableSubtypes(for type: AnimeItemType) -> [AnimeItemSubtype] {
            [.airing, .oneshots]
        }
        
        func topAnimeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem] {
            return []
        }
        
        func favoriteAnimeItems() async throws -> [AnimeItem] {
            return favoriteAnimeItems
        }
        
        func addToFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
            var favorite = animeItem
            favorite.isFavorite = true
            return favorite
        }
        
        func removeFromFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
            var unfavorite = animeItem
            unfavorite.isFavorite = false
            return unfavorite
        }
    }
}
