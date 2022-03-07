//
//  TopAnimeViewController.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Combine
import SafariServices
import UIKit

final class TopAnimeItemListViewController: UIViewController {
    
    // MARK: - Data
    
    private let viewModel: TopAnimeItemListViewModel
    
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
        case top
    }
        
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnimeItem.ID>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnimeItem.ID>
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Lifecycle
    
    init(viewModel: TopAnimeItemListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        if viewModel.animeItems == nil {
            viewModel.reload()
        }
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
                    snapshot.appendSections([.top])
                    snapshot.appendItems(animeItems.map(\.id), toSection: .top)

                    self?.dataSource.apply(snapshot)
                }
            }
            .store(in: &bag)
        
        viewModel.animeItemDidUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] animeItemID in
                if var snapshot = self?.dataSource.snapshot() {
                    snapshot.reconfigureItems([animeItemID])
                    self?.dataSource.apply(snapshot)
                }
            }
            .store(in: &bag)
    }
    
    private func makeDataSource() -> DataSource {
         
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, AnimeItem.ID> { [unowned self] cell, indexPath, identifier in
            
            guard let item = self.viewModel.animeItems?[indexPath.item] else {
                return
            }
            
            var content = AnimeItemConfiguration(
                imageURL: item.imageURL,
                title: item.title,
                rank: item.rank,
                dateText: item.dateText,
                type: item.type,
                isFavorite: item.isFavorite
            )
            content.addToFavoriteHandler = { [unowned viewModel] isFavorite in
                isFavorite ? viewModel.addToFavorites(item) : viewModel.removeFromFavorites(item)
            }
            cell.contentConfiguration = content
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}

extension TopAnimeItemListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let itemIdentifiers = dataSource.snapshot().itemIdentifiers(inSection: .top)
        guard let lastIdentifier = itemIdentifiers.last else {
            return
        }
        
        let identifier = dataSource.snapshot().itemIdentifiers(inSection: .top)[indexPath.item]
        
        if identifier == lastIdentifier {
            viewModel.loadMore()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let url = viewModel.animeItems?[indexPath.item].url else {
            return
        }
        
        // TODO: use coordinator
        let safari = SFSafariViewController(url: url)
        present(safari, animated: true, completion: nil)
    }
}

extension AnimeItem {
    
    var dateText: String {
        [startDate, "-", endDate].compactMap { $0 }.joined(separator: " ")
    }
}
