//
//  UseCaseFactory.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/7.
//

import Foundation

protocol UseCaseFactory {
    func makeAnimeItemUseCase() -> AnimeItemUseCase
}
