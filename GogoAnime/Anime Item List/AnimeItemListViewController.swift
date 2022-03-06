//
//  TopAnimeViewController.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import UIKit

final class AnimeItemListViewController: UIViewController {
    
    // MARK: - Data
    
    // TODO: - DI and ViewModel
    let useCase: AnimeItemUseCase = MyAnimeListAnimeItemUseCase(animeItemRepo: MyAnimeListAnimeItemRepository())
    
    // MARK: - UI
    
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private enum Section: Hashable {
        case topAnime
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnimeItem.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnimeItem.ID>
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Lifecycle
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task {
            do {
                let items = try await useCase.animeItems(type: .anime, subtype: .airing, page: 1)
                
                var snapshot = Snapshot()
                snapshot.appendSections([.topAnime])
                snapshot.appendItems(items.map(\.id))
                
                await dataSource.apply(snapshot)
                
            } catch {
                debugPrint(error)
            }
        }
    }
    
    // MARK: - Private Methods
    
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
