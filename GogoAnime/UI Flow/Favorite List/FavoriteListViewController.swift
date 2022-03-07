//
//  FavoriteListViewController.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/7.
//

import Combine
import UIKit

final class FavoriteListViewController: UIViewController {
    
    // MARK: - Data
    
    let viewModel: FavoriteListViewModel
    
    private var bag = [AnyCancellable]()
    
    // MARK: - UI
    
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private enum Section: Hashable {
        case favorite
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnimeItem.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnimeItem.ID>
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Lifecycle
    
    init(viewModel: FavoriteListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        if viewModel.animeItems.isEmpty {
            viewModel.load()
        }
    }
    
    // MARK: - Private Methods
    
    private func bindViewModel() {
        viewModel.$animeItems
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] animeItems in
                var snapshot = Snapshot()
                snapshot.appendSections([.favorite])
                snapshot.appendItems(animeItems.map(\.id), toSection: .favorite)
                
                self?.dataSource.apply(snapshot)
            }
            .store(in: &bag)
    }
    
    private func makeDataSource() -> DataSource {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, AnimeItem.ID> { [unowned self] cell, indexPath, identifier in
            
            let item = self.viewModel.animeItems[indexPath.item]
            
            let content = AnimeItemConfiguration(
                imageURL: item.imageURL,
                title: item.title,
                rank: item.rank,
                dateText: item.dateText,
                type: item.type,
                isFavorite: item.isFavorite
            )
//            content.addToFavoriteHandler = { [unowned viewModel] isFavorite in
//                isFavorite ? viewModel.addToFavorites(item) : viewModel.removeFromFavorites(item)
//            }
            cell.contentConfiguration = content
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}