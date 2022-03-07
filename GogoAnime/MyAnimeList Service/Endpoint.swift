//
//  Endpoint.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

protocol Endpoint {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var parameters: [String: Any]? { get }
}

extension Endpoint {
    
    var request: URLRequest {
                
        var url = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        
        let pathComponents = (url.path.components(separatedBy: "/") + path.components(separatedBy: "/")).filter { !$0.isEmpty }
        url.path = "/" + pathComponents.joined(separator: "/")
        
        var queryItems: [URLQueryItem]?
        var httpBody: Data?
        
        if let parameters = parameters, !parameters.isEmpty {
            switch httpMethod {
            case .get:
                queryItems = parameters.map { key, value in
                    URLQueryItem(name: key, value: "\(value)")
                }
                
            case .post:
                httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
            }
        }
        url.queryItems = queryItems
        
        var request = URLRequest(url: url.url!)
        request.httpMethod = httpMethod.rawValue
        request.httpBody = httpBody
        
        return request
    }
}
