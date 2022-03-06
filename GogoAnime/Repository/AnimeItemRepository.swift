//
//  AnimeItemRepository.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

protocol AnimeItemRepository {
    func animeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async -> [AnimeItem]
}
