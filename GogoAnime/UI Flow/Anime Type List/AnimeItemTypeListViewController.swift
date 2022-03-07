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
    
    var didSelectTypeHandler: DidSelectTypeHandler?

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
    }
    
    private typealias DataSource = UICollectionViewDiffableDataSource<Section, AnimeItemType>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, AnimeItemType>
    
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
                snapshot.appendSections([.animeItemType])
                snapshot.appendItems(animeTypes, toSection: .animeItemType)
                dataSource.apply(snapshot)
            }
            .store(in: &bag)
    }
    
    // MARK: - Private Methods
    
    private func makeDataSource() -> DataSource {
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, AnimeItemType> { cell, indexPath, identifier in
            var content = cell.defaultContentConfiguration()
            content.text = identifier.rawValue.capitalized
            cell.contentConfiguration = content
        }
        
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }
    }
}

extension AnimeItemTypeListViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let type = dataSource.itemIdentifier(for: indexPath) {
            didSelectTypeHandler?(self, type)
        }
    }
}
