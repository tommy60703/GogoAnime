//
//  APIError.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

enum APIError: Error {
    case notHTTPURLResponse
    case statusCode(Int)
}
