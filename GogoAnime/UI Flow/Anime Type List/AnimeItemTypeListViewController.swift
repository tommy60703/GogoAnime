//
//  AnimeItemTypeListViewController.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Combine
import UIKit

final class AnimeItemTypeListViewController: UIViewController {
    
    // MARK: - Data
    
    typealias DidSelectTypeHandler = (AnimeItemTypeListViewController, AnimeItemType) -> Void
    typealias DidSelectFavoriteHandler = (AnimeItemTypeListViewController) -> Void
    
    var didSelectTypeHandler: DidSelectTypeHandler?
    var didSelectFavoriteHandler: DidSelectFavoriteHandler?

    private let viewModel: AnimeItemTypeListViewModel
    
    private var bag = [AnyCancellable]()
    
    // MARK: - UI
    
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private enum Section: Hashable {
        case animeItemType
        case favorite
    }
    
    private enum Identifier: Hashable {
        case animeItemType(AnimeItemType)
        case favorite
        
        var title: String {
            switch self {
            case .animeItemType(let type): return type.title
            case .favorite: return "My Favorites"
            }
        }
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Identifier>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Identifier>
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Lifecycle
    
    init(viewModel: AnimeItemTypeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Top Anime List"
        navigationItem.backButtonDisplayMode = .generic
        
        collectionView.delegate = self
        
        view.addAutoLayoutSubviews([collectionView])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        viewModel.$animeItemTypes
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] animeTypes in
                var snapshot = Snapshot()
                snapshot.appendSections([.animeItemType, .favorite])
                snapshot.appendItems(animeTypes.map { .animeItemType($0) }, toSection: .animeItemType)
                snapshot.appendItems([.favorite], toSection: .favorite)
                dataSource.apply(snapshot)
            }
            .store(in: &bag)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let indexPath = collectionView.indexPathsForSelectedItems?.first {
            collectionView.deselectItem(at: indexPath, animated: animated)
        }
    }
    
    // MARK: - Private Methods
    
    private func makeDataSource() -> DataSource {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Identifier> { cell, indexPath, identifier in
            
            var content = cell.defaultContentConfiguration()
            content.text = identifier.title
            
            cell.contentConfiguration = content
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}

extension AnimeItemTypeListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let identifier = dataSource.itemIdentifier(for: indexPath) {
            switch identifier {
            case .animeItemType(let type):
                didSelectTypeHandler?(self, type)
                
            case .favorite:
                didSelectFavoriteHandler?(self)
            }
        }
    }
}

extension AnimeItemType {
    
    var title: String {
        switch self {
        case .anime: return "Top Anime"
        case .manga: return "Top Manga"
        }
    }
}
