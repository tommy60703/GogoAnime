//
//  AppAnimeItemUseCaseSpyTests.swift
//  GogoAnimeTests
//
//  Created by Tommy Lin on 2022/3/8.
//

@testable import GogoAnime
import XCTest

class AppAnimeItemUseCaseSpyTests: XCTestCase {
    
    // MARK: - Available types and subtypes
    
    func test_availableAnimeItemTypes() {
        
        // Arrange
        let useCase = AppAnimeItemUseCase(animeItemRepo: SpyTopRepo(), favoriteItemRepo: SpyFavoriteRepo())
        
        // Action
        let availableTypes = useCase.availableTypes()
        
        // Action
        XCTAssertEqual(availableTypes.count, 2)
        XCTAssertTrue(availableTypes.contains(.anime))
        XCTAssertTrue(availableTypes.contains(.manga))
    }
    
    func test_availableAnimeItemSubtypesForAnimeType() {
        
        // Arrange
        let useCase = AppAnimeItemUseCase(animeItemRepo: SpyTopRepo(), favoriteItemRepo: SpyFavoriteRepo())
        
        // Action
        let availableTypes = useCase.availableSubtypes(for: .anime)
        
        // Action
        XCTAssertEqual(availableTypes.count, 8)
        XCTAssertTrue(availableTypes.contains(.airing))
        XCTAssertTrue(availableTypes.contains(.upcoming))
        XCTAssertTrue(availableTypes.contains(.tv))
        XCTAssertTrue(availableTypes.contains(.movie))
        XCTAssertTrue(availableTypes.contains(.ova))
        XCTAssertTrue(availableTypes.contains(.special))
        XCTAssertTrue(availableTypes.contains(.bypopularity))
        XCTAssertTrue(availableTypes.contains(.favorite))
    }
    
    func test_availableAnimeItemSubtypesForMangaType() {
        
        // Arrange
        let useCase = AppAnimeItemUseCase(animeItemRepo: SpyTopRepo(), favoriteItemRepo: SpyFavoriteRepo())
        
        // Action
        let availableTypes = useCase.availableSubtypes(for: .manga)
        
        // Action
        XCTAssertEqual(availableTypes.count, 8)
        XCTAssertTrue(availableTypes.contains(.manga))
        XCTAssertTrue(availableTypes.contains(.novels))
        XCTAssertTrue(availableTypes.contains(.oneshots))
        XCTAssertTrue(availableTypes.contains(.doujin))
        XCTAssertTrue(availableTypes.contains(.manhwa))
        XCTAssertTrue(availableTypes.contains(.manhua))
        XCTAssertTrue(availableTypes.contains(.bypopularity))
        XCTAssertTrue(availableTypes.contains(.favorite))
    }
    
    // MARK: - Top anime items syping
    
    func test_fetchAnimeItems_topAnimeItemRepoDidRecieveQeury() async throws {
        
        // Arrange
        let topRepo = SpyTopRepo()
        let favoriteRepo = SpyFavoriteRepo()
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        _ = try await useCase.topAnimeItems(type: .anime, subtype: nil, page: 1)
        _ = try await useCase.topAnimeItems(type: .anime, subtype: .airing, page: 42)
        _ = try await useCase.topAnimeItems(type: .manga, subtype: .oneshots, page: 43)
        
        // Assert
        let records = topRepo.records
        
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records.map(\.type), [.anime, .anime, .manga])
        XCTAssertEqual(records.map(\.subtype), [nil, .airing, .oneshots])
        XCTAssertEqual(records.map(\.page), [1, 42, 43])
    }
    
    func test_fetchAnimeItems_repoThrowsError_throwsError() async throws {
        
        // Arrange
        let topRepo = SpyTopRepo(throwsError: MockError.mock)
        let favoriteRepo = SpyFavoriteRepo()
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action & Assert
        await XCTAssertThrowsError(try await useCase.topAnimeItems(type: .anime, subtype: nil, page: 1))
    }
    
    // MARK: - Favorite anime items spying
    
    func test_fetchFavoriteItems_favoriteItemRepoDidRecieveQuery() async throws {
        
        // Arrange
        let topRepo = SpyTopRepo()
        let favoriteRepo = SpyFavoriteRepo()
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        _ = try await useCase.favoriteAnimeItems()
        _ = try await useCase.favoriteAnimeItems()
        
        // Assert
        let records = favoriteRepo.fetchRecords
        
        XCTAssertEqual(records.count, 2)
    }
    
    func test_fetchFavoriteItems_repoThrowsError_throwsError() async throws {
        
        // Arrange
        let topRepo = SpyTopRepo()
        let favoriteRepo = SpyFavoriteRepo(throwsError: MockError.mock)
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action & Assert
        await XCTAssertThrowsError(try await useCase.favoriteAnimeItems())
    }
    
    func test_addFavoriteItems_favoriteItemRepoDidRecieveQuery() async throws {
        
        // Arrange
        let topRepo = SpyTopRepo()
        let favoriteRepo = SpyFavoriteRepo()
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        let sampleItem = AnimeItem.dummy
        _ = try await useCase.addToFavorites(sampleItem)
        _ = try await useCase.addToFavorites(sampleItem)
        _ = try await useCase.addToFavorites(sampleItem)
        
        // Assert
        let records = favoriteRepo.addRecords
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records.map(\.animeItem), [sampleItem, sampleItem, sampleItem])
    }
    
    func test_addFavoriteItems_repoThrowsError_throwsError() async throws {
        
        // Arrange
        let topRepo = SpyTopRepo()
        let favoriteRepo = SpyFavoriteRepo(throwsError: MockError.mock)
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action & Assert
        let sampleItem = AnimeItem.dummy
        await XCTAssertThrowsError(try await useCase.addToFavorites(sampleItem))
    }
    
    func test_RemoveFavoriteItems_favoriteItemRepoDidRecieveQuery() async throws {
        
        // Arrange
        let topRepo = SpyTopRepo()
        let favoriteRepo = SpyFavoriteRepo()
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action
        let sampleItem = AnimeItem.dummy
        _ = try await useCase.removeFromFavorites(sampleItem)
        _ = try await useCase.removeFromFavorites(sampleItem)
        _ = try await useCase.removeFromFavorites(sampleItem)
        
        // Assert
        let records = favoriteRepo.removeRecords
        XCTAssertEqual(records.count, 3)
        XCTAssertEqual(records.map(\.animeItem), [sampleItem, sampleItem, sampleItem])
    }
    
    func test_removeFavoriteItems_repoThrowsError_throwsError() async throws {
        
        // Arrange
        let topRepo = SpyTopRepo()
        let favoriteRepo = SpyFavoriteRepo(throwsError: MockError.mock)
        let useCase = AppAnimeItemUseCase(animeItemRepo: topRepo, favoriteItemRepo: favoriteRepo)
        
        // Action & Assert
        let sampleItem = AnimeItem.dummy
        await XCTAssertThrowsError(try await useCase.removeFromFavorites(sampleItem))
    }
}

// MARK: - Mocks and Spies

extension AppAnimeItemUseCaseSpyTests {
    
    private enum MockError: Error {
        case mock
    }
    
    private class SpyTopRepo: TopAnimeItemRepository {
        
        typealias Record = (type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int)
        
        private(set) var records = [Record]()
        
        private let errorToThrow: Error?
        
        init(throwsError: Error? = nil) {
            self.errorToThrow = throwsError
        }
        
        func topAnimeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem] {
            records.append((type, subtype, page))
            
            if let errorToThrow = errorToThrow {
                throw errorToThrow
            }
            return []
        }
    }
    
    private class SpyFavoriteRepo: FavoriteAnimeItemRepository {
        
        struct FetchRecord {}
        struct AddRecord {
            var animeItem: AnimeItem
        }
        struct RemoveRecord {
            var animeItem: AnimeItem
        }
        
        private(set) var fetchRecords = [FetchRecord]()
        private(set) var addRecords = [AddRecord]()
        private(set) var removeRecords = [RemoveRecord]()
        
        private let errorToThrow: Error?
        
        init(throwsError: Error? = nil) {
            self.errorToThrow = throwsError
        }
        func favoriteAnimeItems() async throws -> [AnimeItem] {
            fetchRecords.append(FetchRecord())

            if let errorToThrow = errorToThrow {
                throw errorToThrow
            }
            return []
        }
        
        func addToFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
            addRecords.append(AddRecord(animeItem: animeItem))
            
            if let errorToThrow = errorToThrow {
                throw errorToThrow
            }
            return animeItem
        }
        
        func removeFromFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
            removeRecords.append(RemoveRecord(animeItem: animeItem))
            
            if let errorToThrow = errorToThrow {
                throw errorToThrow
            }
            return animeItem
        }
    }
}

private extension AnimeItem {
    
    static var dummy: AnimeItem {
        AnimeItem(
            id: 42,
            urlString: nil,
            imageURLString: nil,
            title: "title",
            rank: 1,
            startDate: nil,
            endDate: nil,
            type: "type",
            isFavoriteOrNil: nil
        )
    }
}
