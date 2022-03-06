//
//  AnimeItemUseCase.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Foundation

protocol AnimeItemUseCase {
    var animeItemRepo: AnimeItemRepository { get }
    
    func avilableSubtypes(for type: AnimeItemType) -> [AnimeItemSubtype]
    func animeItems(type: AnimeItemType, subtype: AnimeItemSubtype?, page: Int) async throws -> [AnimeItem]
}
