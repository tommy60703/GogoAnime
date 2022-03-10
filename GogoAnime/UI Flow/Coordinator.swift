//
//  Coordinator.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/7.
//

import SafariServices
import UIKit

final class AppCoordinator {
    
    let navigationController = UINavigationController()
    
    private let useCaseFactory: UseCaseFactory
    
    init(useCaseFactory: UseCaseFactory) {
        self.useCaseFactory = useCaseFactory
    }
    
    func start() {
        let useCase = useCaseFactory.makeAnimeItemUseCase()
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
        let useCase = useCaseFactory.makeAnimeItemUseCase()
        let viewModel = AnimeItemSubtypeListViewModel(useCase: useCase, type: animeItemType)
        let viewController = AnimeItemSubtypeListViewController(viewModel: viewModel)
        viewController.didSelectTypeHandler = { [unowned self] _, type, subtype in
            navigateToAnimeItemList(animeItemType: type, subtype: subtype)
        }
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func navigateToAnimeItemList(animeItemType: AnimeItemType, subtype: AnimeItemSubtype?, animated: Bool = true) {
        let useCase = useCaseFactory.makeAnimeItemUseCase()
        let viewModel = TopAnimeItemListViewModel(useCase: useCase, type: animeItemType, subtype: subtype)
        let viewController = TopAnimeItemListViewController(viewModel: viewModel)
        viewController.didSelectAnimeItemHandler = { [unowned self] _, animeItem in
            if let url = animeItem.url {
                presentAnimeItemDetail(url: url)
            }
        }
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func navigateToFavoriteList(animated: Bool = true) {
        let useCase = useCaseFactory.makeAnimeItemUseCase()
        let viewModel = FavoriteListViewModel(useCase: useCase)
        let viewController = FavoriteListViewController(viewModel: viewModel)
        viewController.didSelectAnimeItemHandler = { [unowned self] _, animeItem in
            if let url = animeItem.url {
                presentAnimeItemDetail(url: url)
            }
        }
        
        navigationController.pushViewController(viewController, animated: animated)
    }
    
    func presentAnimeItemDetail(url: URL, animated: Bool = true) {
        let safari = SFSafariViewController(url: url)
        navigationController.present(safari, animated: animated, completion: nil)
    }
}
