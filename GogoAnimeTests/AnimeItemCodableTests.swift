//
//  AnimeItemTests.swift
//  GogoAnimeTests
//
//  Created by Tommy Lin on 2022/3/7.
//

@testable import GogoAnime
import XCTest

class AnimeItemCodableTests: XCTestCase {

    func test_decodeFromJSON_withRequiredFields_decodeSuccessful() throws {
        
        // Arrange
        let json = """
            {
                "mal_id": 9527,
                "title": "Title",
                "rank": 42,
                "type": "anime"
            }
        """.data(using: .utf8)!
        
        // Action
        let decoder = JSONDecoder()
        let animeItem = try decoder.decode(AnimeItem.self, from: json)
        
        // Assert
        XCTAssertEqual(animeItem.id, 9527)
        XCTAssertEqual(animeItem.title, "Title")
        XCTAssertEqual(animeItem.rank, 42)
        XCTAssertEqual(animeItem.type, "anime")
        XCTAssertFalse(animeItem.isFavorite)
        
        XCTAssertNil(animeItem.urlString)
        XCTAssertNil(animeItem.url)
        XCTAssertNil(animeItem.imageURLString)
        XCTAssertNil(animeItem.imageURL)
        XCTAssertNil(animeItem.startDate)
        XCTAssertNil(animeItem.endDate)
    }
    
    func test_decodeFromJSON_withAllOptionalFields_decodeSuccessful() throws {
        
        // Arrange
        let json = """
            {
                "mal_id": 9527,
                "url": "https://httpbin.org/get",
                "image_url": "https://httpbin.org/image",
                "title": "Title",
                "rank": 42,
                "start_date": "Jan 2022",
                "end_date": "Mar 2022",
                "type": "anime"
            }
        """.data(using: .utf8)!
        
        // Action
        let decoder = JSONDecoder()
        let animeItem = try decoder.decode(AnimeItem.self, from: json)
        
        // Assert
        XCTAssertEqual(animeItem.id, 9527)
        XCTAssertEqual(animeItem.urlString, "https://httpbin.org/get")
        XCTAssertEqual(animeItem.url, URL(string: "https://httpbin.org/get"))
        XCTAssertEqual(animeItem.imageURLString, "https://httpbin.org/image")
        XCTAssertEqual(animeItem.imageURL, URL(string: "https://httpbin.org/image"))
        XCTAssertEqual(animeItem.title, "Title")
        XCTAssertEqual(animeItem.rank, 42)
        XCTAssertEqual(animeItem.startDate, "Jan 2022")
        XCTAssertEqual(animeItem.endDate, "Mar 2022")
        XCTAssertEqual(animeItem.type, "anime")
        XCTAssertFalse(animeItem.isFavorite)
    }
    
    func test_decodeFromJSON_withoutIsFavoriteField_isFavoriteEqualsToFalse() throws {
        
        // Arrange
        let json = """
            {
                "mal_id": 9527,
                "title": "Title",
                "rank": 42,
                "type": "anime"
            }
        """.data(using: .utf8)!
        
        // Action
        let decoder = JSONDecoder()
        let animeItem = try decoder.decode(AnimeItem.self, from: json)
        
        // Assert
        XCTAssertFalse(animeItem.isFavorite)
    }
    
    func test_decodeFromJSON_withIsFavoriteFieldEqualsToFalse_isFavoriteEqualsToFalse() throws {
        
        // Arrange
        let json = """
            {
                "mal_id": 9527,
                "title": "Title",
                "rank": 42,
                "type": "anime",
                "isFavoriteOrNil": false
            }
        """.data(using: .utf8)!
        
        // Action
        let decoder = JSONDecoder()
        let animeItem = try decoder.decode(AnimeItem.self, from: json)
        
        // Assert
        XCTAssertFalse(animeItem.isFavorite)
    }
    
    func test_decodeFromJSON_withIsFavoriteFieldEqualsToTrue_isFavoriteEqualsToTrue() throws {
        
        // Arrange
        let json = """
            {
                "mal_id": 9527,
                "title": "Title",
                "rank": 42,
                "type": "anime",
                "isFavoriteOrNil": true
            }
        """.data(using: .utf8)!
        
        // Action
        let decoder = JSONDecoder()
        let animeItem = try decoder.decode(AnimeItem.self, from: json)
        
        // Assert
        XCTAssertTrue(animeItem.isFavorite)
    }
}
