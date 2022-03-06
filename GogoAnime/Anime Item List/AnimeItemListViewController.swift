//
//  TopAnimeViewController.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Combine
import UIKit

final class AnimeItemListViewController: UIViewController {
    
    // MARK: - Data
    
    // TODO: - DI and ViewModel
    private let viewModel: AnimeItemListViewModel = {
        let useCase: AnimeItemUseCase = MyAnimeListAnimeItemUseCase(animeItemRepo: MyAnimeListAnimeItemRepository())
        return AnimeItemListViewModel(useCase: useCase, type: .anime, subtype: .airing)
    }()
    
    private var bag = [AnyCancellable]()
    
    // MARK: - UI
    
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private lazy var refreshControl = UIRefreshControl(frame: .zero, primaryAction: UIAction { _ in
        self.viewModel.reload()
    })
    
    private enum Section: Hashable {
        case topAnime
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnimeItem.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnimeItem.ID>
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.refreshControl = refreshControl
        collectionView.delegate = self
        
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reload()
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.$reloadState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                if !state.isLoading {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &bag)
        
        viewModel.$animeItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] animeItems in
                if let animeItems = animeItems {
                    var snapshot = Snapshot()
                    snapshot.appendSections([.topAnime])
                    snapshot.appendItems(animeItems.map(\.id), toSection: .topAnime)

                    self?.dataSource.apply(snapshot)
                }
            }
            .store(in: &bag)
    }
    
    private func makeDataSource() -> DataSource {
        // TODO: - set up with anime item 
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnimeItem.ID> { cell, indexPath, identifier in
            var content = cell.defaultContentConfiguration()
            content.text = "Anime #\(identifier)"
            cell.contentConfiguration = content
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}

extension AnimeItemListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let itemIdentifiers = dataSource.snapshot().itemIdentifiers(inSection: .topAnime)
        guard let lastIdentifier = itemIdentifiers.last else {
            return
        }
        
        let identifier = dataSource.snapshot().itemIdentifiers(inSection: .topAnime)[indexPath.item]
        
        if identifier == lastIdentifier {
            viewModel.loadMore()
        }
    }
}
