//
//  EndpointTests.swift
//  GogoAnimeTests
//
//  Created by Tommy Lin on 2022/3/7.
//

@testable import GogoAnime
import XCTest

class EndpointTests: XCTestCase {

    struct MockEndpoint: Endpoint {
        var baseURL: URL
        var path: String
        var httpMethod: HTTPMethod
        var parameters: [String: Any]?
    }
    
    func test_baseURLWithoutPath_createRequest_getRequestWithoutURLPath() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/")!,
            path: "",
            httpMethod: .get,
            parameters: nil
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true))
        
        XCTAssertEqual(components.path, "/")
    }
    
    func test_baseURLWithoutPathAndPath_createRequest_getRequestWithURLPath() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/")!,
            path: "path",
            httpMethod: .get,
            parameters: nil
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true))
        
        XCTAssertEqual(components.path, "/path")
    }
    
    func test_baseURLWithPath_createRequest_getRequestWithURLPath() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/get")!,
            path: "",
            httpMethod: .get,
            parameters: nil
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true))
        
        XCTAssertEqual(components.path, "/get")
    }
    
    func test_baseURLWithPathAndPath_createRequest_getRequestWithURLPath() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/get")!,
            path: "path",
            httpMethod: .get,
            parameters: nil
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        let url = try XCTUnwrap(request.url)
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true))
        
        XCTAssertEqual(components.path, "/get/path")
    }

    func test_endpointWithGETMethod_createRequestWithoutParamenters_getRequestWithoutQueryItems() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/get")!,
            path: "",
            httpMethod: .get,
            parameters: nil
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        XCTAssertEqual(request.url, URL(string: "https://httpbin.org/get"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }
    
    func test_endpointWithGETMethod_createRequestWithEmptyParamenters_getRequestWithoutQueryItems() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/get")!,
            path: "",
            httpMethod: .get,
            parameters: [:]
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        XCTAssertEqual(request.url, URL(string: "https://httpbin.org/get"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
    }
    
    func test_endpointWithPOSTMethod_createRequestWithoutParameters_getRequestWithoutHTTPBody() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/post")!,
            path: "",
            httpMethod: .post,
            parameters: nil
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        XCTAssertEqual(request.url, URL(string: "https://httpbin.org/post"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNil(request.httpBody)
    }
    
    func test_endpointWithPOSTMethod_createRequestWithEmptyParameters_getRequestWithoutHTTPBody() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/post")!,
            path: "",
            httpMethod: .post,
            parameters: [:]
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        XCTAssertEqual(request.url, URL(string: "https://httpbin.org/post"))
        XCTAssertEqual(request.httpMethod, "POST")
        XCTAssertNil(request.httpBody)
    }
    
    func test_endpointWithGETMethod_createRequest_getRequestWithQueryItems() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/get")!,
            path: "",
            httpMethod: .get,
            parameters: ["foo": "bar", "baz": 42]
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        XCTAssertNotEqual(request.url, URL(string: "https://httpbin.org/get"))
        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertNil(request.httpBody)
        
        let url = try XCTUnwrap(request.url)
        let urlComponents = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: true))
        let queryItems = try XCTUnwrap(urlComponents.queryItems)
        
        XCTAssertEqual(queryItems.count, 2)
        
        let query = queryItems.reduce(into: [String: String?]()) { partialResult, queryItem in
            partialResult[queryItem.name] = queryItem.value
        }
        XCTAssertEqual(query["foo"], "bar")
        XCTAssertEqual(query["baz"], "42")
    }
    
    func test_endpointWithPOSTMethod_createRequest_getRequestWithHTTPBody() throws {
        
        // Arrange
        let endpoint = MockEndpoint(
            baseURL: URL(string: "https://httpbin.org/post")!,
            path: "",
            httpMethod: .post,
            parameters: [
                "string": "foobar",
                "int": 42,
                "double": 12.3,
                "boolean": true
            ]
        )
        
        // Action
        let request = endpoint.request
        
        // Assert
        XCTAssertEqual(request.url, URL(string: "https://httpbin.org/post"))
        XCTAssertEqual(request.httpMethod, "POST")
        
        let httpBody = try XCTUnwrap(request.httpBody)
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: Any])
        
        XCTAssertEqual(try XCTUnwrap(json["string"] as? String), "foobar")
        XCTAssertEqual(try XCTUnwrap(json["int"] as? Int), 42)
        XCTAssertEqual(try XCTUnwrap(json["double"] as? Double), 12.3, accuracy: 0.001)
        XCTAssertTrue(try XCTUnwrap(json["boolean"] as? Bool))
    }
}
