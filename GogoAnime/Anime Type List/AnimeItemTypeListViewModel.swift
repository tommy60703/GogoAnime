//
//  AnimeItemTypeListViewModel.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Combine
import Foundation

final class AnimeItemTypeListViewModel {
    
    @Published private(set) var animeItemTypes: [AnimeItemType]
    
    private let useCase: AnimeItemUseCase
    
    init(useCase: AnimeItemUseCase) {
        self.useCase = useCase
        self.animeItemTypes = useCase.availableTypes()
    }
}
