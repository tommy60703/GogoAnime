//
//  AppAnimeItemUseCaseFavoriteTests.swift
//  GogoAnimeTests
//
//  Created by Tommy Lin on 2022/3/8.
//

@testable import GogoAnime
import XCTest

class AppAnimeItemUseCaseFavoriteTests: XCTestCase {
    
    func test_fetchTopAnimeItems_returnsAnimeItemsWithCorrectFavoriteState() async throws {
        
        // Arrange
        let topItems = [1, 2, 3, 4, 5].map { id in
            AnimeItem(id: id, urlString: nil, imageURLString: nil, title: "\(id)", rank: id, startDate: nil, endDate: nil, type: "\(id)", isFavoriteOrNil: nil)
        }
        let favoriteItems = [4, 5, 6].map { id in
            AnimeItem(id: id, urlString: nil, imageURLString: nil, title: "\(id)", rank: id, startDate: nil, endDate: nil, type: "\(id)", isFavoriteOrNil: true)
        }
        
        let topRepo = MockTopRepo(animeItems: topItems)
        let favoriteRepo = MockFavoriteRepo(animeItems: favoriteItems)
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        let topItemsResult = try await useCase.topAnimeItems(type: .anime, subtype: .airing, page: 1)
        let favoriteItemsResult = try await useCase.favoriteAnimeItems()
        
        // Assert
        XCTAssertEqual(topItemsResult.map(\.id), [1, 2, 3, 4, 5])
        XCTAssertEqual(topItemsResult.map(\.isFavorite), [false, false, false, true, true])

        XCTAssertEqual(favoriteItemsResult.map(\.id), [4, 5, 6])
        XCTAssertEqual(favoriteItemsResult.map(\.isFavorite), [true, true, true])
    }
    
    func test_addToFavorites_didAddToFavorites() async throws {
        
        // Arrange
        let originalItem = AnimeItem(id: 1, urlString: nil, imageURLString: nil, title: "title", rank: 1, startDate: nil, endDate: nil, type: "type", isFavoriteOrNil: nil)
        
        let topRepo = MockTopRepo(animeItems: [originalItem])
        let favoriteRepo = MockFavoriteRepo(animeItems: [])
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        _ = try await useCase.addToFavorites(originalItem)
        let favoriteItems = try await useCase.favoriteAnimeItems()
        
        // Assert
        XCTAssertEqual(favoriteItems.map(\.id), [1])
    }
    
    func test_addToFavorites_didUpdateTopItems() async throws {
        
        // Arrange
        let originalItem = AnimeItem(id: 1, urlString: nil, imageURLString: nil, title: "title", rank: 1, startDate: nil, endDate: nil, type: "type", isFavoriteOrNil: nil)
        
        let topRepo = MockTopRepo(animeItems: [originalItem])
        let favoriteRepo = MockFavoriteRepo(animeItems: [])
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        _ = try await useCase.addToFavorites(originalItem)
        let topItems = try await useCase.topAnimeItems(type: .anime, subtype: nil, page: 1)
        
        // Assert
        var expectedItem = originalItem
        expectedItem.isFavorite = true
        
        XCTAssertEqual(topItems, [expectedItem])
    }
    
    func test_removeFromFavorites_didRemoveFromFavorites() async throws {
        
        // Arrange
        let originalItem = AnimeItem(id: 1, urlString: nil, imageURLString: nil, title: "title", rank: 1, startDate: nil, endDate: nil, type: "type", isFavoriteOrNil: true)
        
        let topRepo = MockTopRepo(animeItems: [originalItem])
        let favoriteRepo = MockFavoriteRepo(animeItems: [originalItem])
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        _ = try await useCase.removeFromFavorites(originalItem)
        let favoriteItems = try await useCase.favoriteAnimeItems()
        
        // Assert
        XCTAssertEqual(favoriteItems, [])
    }
    
    func test_removeFromFavorites_didUpdateTopItems() async throws {
        
        // Arrange
        let originalItem = AnimeItem(id: 1, urlString: nil, imageURLString: nil, title: "title", rank: 1, startDate: nil, endDate: nil, type: "type", isFavoriteOrNil: true)
        
        let topRepo = MockTopRepo(animeItems: [originalItem])
        let favoriteRepo = MockFavoriteRepo(animeItems: [originalItem])
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        _ = try await useCase.removeFromFavorites(originalItem)
        let topItems = try await useCase.topAnimeItems(type: .anime, subtype: nil, page: 1)
        
        // Assert
        var expectedItem = originalItem
        expectedItem.isFavorite = false
        
        XCTAssertEqual(topItems, [expectedItem])
    }
}

extension AppAnimeItemUseCaseFavoriteTests {
    
    private class MockTopRepo: TopAnimeItemRepository {
        
        private let animeItems: [AnimeItem]
        
        init(animeItems: [AnimeItem]) {
            self.animeItems = animeItems
        }
        
        func topAnimeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem] {
            animeItems
        }
    }
    
    private class MockFavoriteRepo: FavoriteAnimeItemRepository {
        
        private var animeItems: [AnimeItem]
        
        init(animeItems: [AnimeItem]) {
            self.animeItems = animeItems
        }
        
        func favoriteAnimeItems() async throws -> [AnimeItem] {
            animeItems
        }
        
        func addToFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
            animeItems.append(animeItem)
            return animeItem
        }
        
        func removeFromFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
            animeItems.removeAll(where: { $0.id == animeItem.id })
            return animeItem
        }
    }
}
