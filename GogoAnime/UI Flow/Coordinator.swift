//
//  Coordinator.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/7.
//

import UIKit

final class AppCoordinator {
    
    private let animeItemRepo: AnimeItemRepository = MyAnimeListAnimeItemRepository()
    private let favoriteAnimeItemRepo: FavoriteAnimeItemRepository = LocalFavoriteAnimeItemRepository()
    
    let navigationController = UINavigationController()
    
    func start() {
        let useCase = AppAnimeItemUseCase(animeItemRepo: animeItemRepo, favoriteItemRepo: favoriteAnimeItemRepo)
        let viewModel = AnimeItemTypeListViewModel(useCase: useCase)
        let viewController = AnimeItemTypeListViewController(viewModel: viewModel)
        viewController.didSelectTypeHandler = { [unowned self] _, type in
            navigateToAnimeItemSubtypeList(animeItemType: type)
        }
        viewController.didSelectFavoriteHandler = { [unowned self] _ in
            navigateToFavoriteList()
        }
        
        navigationController.pushViewController(viewController, animated: false)
    }
    
    func navigateToAnimeItemSubtypeList(animeItemType: AnimeItemType, animated: Bool = true) {
        let useCase = AppAnimeItemUseCase(animeItemRepo: animeItemRepo, favoriteItemRepo: favoriteAnimeItemRepo)
        let viewModel = AnimeItemSubtypeListViewModel(useCase: useCase, type: animeItemType)
        let viewController = AnimeItemSubtypeListViewController(viewModel: viewModel)
        viewController.didSelectTypeHandler = { [unowned self] _, type, subtype in
            navigateToAnimeItemList(animeItemType: type, subtype: subtype)
        }
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func navigateToAnimeItemList(animeItemType: AnimeItemType, subtype: AnimeItemSubtype?, animated: Bool = true) {
        let useCase = AppAnimeItemUseCase(animeItemRepo: animeItemRepo, favoriteItemRepo: favoriteAnimeItemRepo)
        let viewModel = AnimeItemListViewModel(useCase: useCase, type: animeItemType, subtype: subtype)
        let viewController = AnimeItemListViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func navigateToFavoriteList(animated: Bool = true) {
        let useCase = AppAnimeItemUseCase(animeItemRepo: animeItemRepo, favoriteItemRepo: favoriteAnimeItemRepo)
        let viewModel = FavoriteListViewModel(useCase: useCase)
        let viewController = FavoriteListViewController(viewModel: viewModel)
        
        navigationController.pushViewController(viewController, animated: animated)
    }
}
