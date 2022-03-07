//
//  AnimeItemSubtypeListViewModel.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Combine
import Foundation

final class AnimeItemSubtypeListViewModel {
    
    @Published private(set) var animeItemSubtypes: [AnimeItemSubtype]
    
    let type: AnimeItemType
    private let useCase: AnimeItemUseCase
    
    init(useCase: AnimeItemUseCase, type: AnimeItemType) {
        self.useCase = useCase
        self.type = type
        self.animeItemSubtypes = useCase.availableSubtypes(for: type)
    }
}
