//
//  TopAnimeItemListViewModelTests.swift
//  GogoAnimeTests
//
//  Created by Tommy Lin on 2022/3/8.
//

@testable import GogoAnime
import XCTest

class TopAnimeItemListViewModelTests: XCTestCase {
    
    private var useCase: SpykUseCase!
    private var viewModel: TopAnimeItemListViewModel!
        
    override func setUpWithError() throws {
        try super.setUpWithError()
        useCase = SpykUseCase()
        viewModel = TopAnimeItemListViewModel(useCase: useCase, type: .anime, subtype: .tv)
    }
    
    // MARK: - reload and load more
    
    func test_reload_useCaseDidFetchTopAnimeItems() async throws {
        
        // Arrange
        
        // Action
        await viewModel.reload()
        
        // Assert
        XCTAssertEqual(useCase.pageRecords, [1])
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func test_reloadConcurrently_useCaseDidFetchTopAnimeItemsOnce() async throws {
        
        // Arrange
        let expectation = expectation(description: "reload twice")
        expectation.expectedFulfillmentCount = 2
        
        // Action
        Task {
            await viewModel.reload()
            expectation.fulfill()
        }
    
        Task {
            await viewModel.reload()
            expectation.fulfill()
        }
        
        await waitForExpectations(timeout: 10, handler: nil)
        
        // Assert
        XCTAssertEqual(useCase.pageRecords, [1])
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    func test_loadMore_useCaseDidFetchMoreTopAnimeItems() async throws {
        
        // Arrange
        
        // Action
        await viewModel.reload() // page 1
        await viewModel.loadMore() // page 2
        await viewModel.loadMore() // page 3
        
        // Assert
        XCTAssertEqual(useCase.pageRecords, [1, 2, 3])
        XCTAssertEqual(viewModel.currentPage, 3)
    }
    
    func test_loadMoreConcurrently_useCaseDidFetchMoreTopAnimeItemsOnce() async throws {
        
        // Arrange
        let expectation = expectation(description: "load more twice")
        expectation.expectedFulfillmentCount = 2
        
        // Action
        await viewModel.reload() // page 1
        
        Task {
            await viewModel.loadMore() // page 2
            expectation.fulfill()
        }
        Task {
            await viewModel.loadMore() // page 2
            expectation.fulfill()
        }
        
        await waitForExpectations(timeout: 10, handler: nil)
        
        // Assert
        XCTAssertEqual(useCase.pageRecords, [1, 2])
        XCTAssertEqual(viewModel.currentPage, 2)
    }
    
    func test_reloadWhenLoadingMore_willReloadAndCancelLoadMore() async throws {
        
        // Arrange
        let expectation = expectation(description: "load more")
        expectation.expectedFulfillmentCount = 2
        
        // Action
        await viewModel.reload() // page 1
        await viewModel.loadMore() // page 2
        
        Task {
            await viewModel.loadMore() // page 3
            expectation.fulfill()
        }
        Task {
            await viewModel.reload() // page 1
            expectation.fulfill()
        }
        
        await waitForExpectations(timeout: 10, handler: nil)
        
        // Assert
        XCTAssertEqual(useCase.pageRecords, [1, 2, 3, 1])
                
        XCTAssertEqual(viewModel.animeItems.map(\.id), [1])
        XCTAssertEqual(viewModel.currentPage, 1)
    }
    
    // MARK: - reload state
    
    func test_reload_didUpdateReloadState() async throws {
        
        // Arrange
        var stateRecords: [ViewModelState] = [viewModel.reloadState]
        let expectation = expectation(description: "reload state")
        
        // Action
        Task {
            await viewModel.reload()
            expectation.fulfill()
        }
                
        let stateAfterReload = Task { viewModel.reloadState }
        stateRecords.append(await stateAfterReload.value)
        
        await waitForExpectations(timeout: 10, handler: nil)
        
        stateRecords.append(viewModel.reloadState)
        
        // Assert
        XCTAssertEqual(stateRecords.count, 3)
        XCTAssertTrue(stateRecords[0].isIdle)
        XCTAssertTrue(stateRecords[1].isLoading)
        XCTAssertTrue(stateRecords[2].isIdle)
    }
    
    // MARK: - load more state
    
    func test_loadMore_didUpdateLoadMoreState() async throws {
        
        // Arrange
        var stateRecords: [ViewModelState] = [viewModel.loadMoreState]
        let expectation = expectation(description: "load more state")
        
        // Action
        
        Task {
            await viewModel.loadMore()
            expectation.fulfill()
        }
        
        let stateAfterLoadMore = Task { viewModel.loadMoreState }
        
        stateRecords.append(await stateAfterLoadMore.value)
        
        await waitForExpectations(timeout: 10, handler: nil)
        
        stateRecords.append(viewModel.loadMoreState)
        
        // Assert
        XCTAssertEqual(stateRecords.count, 3)
        XCTAssertTrue(stateRecords[0].isIdle)
        XCTAssertTrue(stateRecords[1].isLoading)
        XCTAssertTrue(stateRecords[2].isIdle)
    }
    
    func test_loadMoreThenReload_didUpdateLoadMoreState() async throws {
        
        // Arrange
        var stateRecords: [ViewModelState] = [viewModel.loadMoreState]
        let expectation = expectation(description: "load more state")
        expectation.expectedFulfillmentCount = 2
        
        // Action
        Task {
            await viewModel.loadMore()
            expectation.fulfill()
        }
                
        let stateAfterLoadMore = Task { viewModel.loadMoreState }
        stateRecords.append(await stateAfterLoadMore.value) // isLoading

        Task {
            await viewModel.reload() // should reset load more state
            expectation.fulfill()
        }
        
        let stateAfterReload = Task { viewModel.loadMoreState }
        stateRecords.append(await stateAfterReload.value) // isIdle
        
        await waitForExpectations(timeout: 10, handler: nil)
                
        // Assert
        XCTAssertEqual(stateRecords.count, 3)
        XCTAssertTrue(stateRecords[0].isIdle)
        XCTAssertTrue(stateRecords[1].isLoading)
        XCTAssertTrue(stateRecords[2].isIdle)
    }
}

extension TopAnimeItemListViewModelTests {
    
    private class SpykUseCase: AnimeItemUseCase {
                
        private(set) var pageRecords = [Int]()
        
        var sleepDuration = TimeInterval(NSEC_PER_MSEC) / TimeInterval(NSEC_PER_SEC)
        
        private var nanoseconds: UInt64 {
            UInt64(sleepDuration * TimeInterval(NSEC_PER_SEC))
        }
        
        func availableTypes() -> [AnimeItemType] {
            [.anime, .manga]
        }
        
        func availableSubtypes(for type: AnimeItemType) -> [AnimeItemSubtype] {
            [.airing, .oneshots]
        }
        
        func topAnimeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem] {
            try await Task.sleep(nanoseconds: nanoseconds)
            pageRecords.append(page)
            
            let animeItem = AnimeItem(id: page, urlString: nil, imageURLString: nil, title: "\(page)", rank: page, startDate: nil, endDate: nil, type: "\(page)", isFavoriteOrNil: nil)
            return [animeItem]
        }
        
        func favoriteAnimeItems() async throws -> [AnimeItem] {
            try await Task.sleep(nanoseconds: nanoseconds)
            return []
        }
        
        func addToFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
            try await Task.sleep(nanoseconds: nanoseconds)
            
            var favorite = animeItem
            favorite.isFavorite = true
            return favorite
        }
        
        func removeFromFavorites(_ animeItem: AnimeItem) async throws -> AnimeItem {
            try await Task.sleep(nanoseconds: nanoseconds)
            
            var unfavorite = animeItem
            unfavorite.isFavorite = false
            return unfavorite
        }
    }
}
