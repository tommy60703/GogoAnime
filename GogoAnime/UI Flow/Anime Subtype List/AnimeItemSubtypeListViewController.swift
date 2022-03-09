//
//  AnimeItemSubtypeListViewController.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Combine
import UIKit

final class AnimeItemSubtypeListViewController: UIViewController {
    
    // MARK: - Data

    typealias DidSelectTypeHandler = (AnimeItemSubtypeListViewController, AnimeItemType, AnimeItemSubtype?) -> Void
    
    var didSelectTypeHandler: DidSelectTypeHandler?
    
    private let viewModel: AnimeItemSubtypeListViewModel
    
    private var bag = [AnyCancellable]()
    
    // MARK: - UI
    
    private let collectionView: UICollectionView = {
        let config = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private enum Section: Hashable {
        case animeItemSubtype
    }
    
    private enum Identifier: Hashable {
        case all
        case subtype(AnimeItemSubtype)
        
        var title: String {
            switch self {
            case .all: return "All"
            case .subtype(let subtype): return subtype.title
            }
        }
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, Identifier>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Identifier>
    
    private lazy var dataSource = makeDataSource()
    
    // MARK: - Lifecycle
    
    init(viewModel: AnimeItemSubtypeListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = viewModel.type.navigationTitle
        
        collectionView.delegate = self
        
        view.addAutoLayoutSubviews([collectionView])
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        viewModel.$animeItemSubtypes
            .receive(on: DispatchQueue.main)
            .sink { [unowned self] subtypes in
                let items = [Identifier.all] + subtypes.map { .subtype($0) }
                
                var snapshot = Snapshot()
                snapshot.appendSections([.animeItemSubtype])
                snapshot.appendItems(items, toSection: .animeItemSubtype)
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

extension AnimeItemSubtypeListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let type = viewModel.type
        if let identifier = dataSource.itemIdentifier(for: indexPath) {
            
            let subtype: AnimeItemSubtype? = {
                switch identifier {
                case .all: return nil
                case .subtype(let subtype): return subtype
                }
            }()
            
            didSelectTypeHandler?(self, type, subtype)
        }
    }
}

private extension AnimeItemType {
    
    var navigationTitle: String {
        switch self {
        case .anime: return "Top Anime"
        case .manga: return "Top Manga"
        }
    }
}

extension AnimeItemSubtype {
    
    var title: String {
        switch self {
        case .airing:
            return "Top Airing"
        case .upcoming:
            return "Top Upcoming"
        case .tv:
            return "Top TV Series"
        case .movie:
            return "Top Movies"
        case .ova:
            return "Top OVAs"
        case .special:
            return "Top Specials"
        case .manga:
            return "Top Manga"
        case .novels:
            return "Top Light Novels"
        case .oneshots:
            return "Top One-shots"
        case .doujin:
            return "Top Doujinshi"
        case .manhwa:
            return "Top Manhwa"
        case .manhua:
            return "Top Manhua"
        case .bypopularity:
            return "Most Popular"
        case .favorite:
            return "Most Favorited"
        }
    }
}
