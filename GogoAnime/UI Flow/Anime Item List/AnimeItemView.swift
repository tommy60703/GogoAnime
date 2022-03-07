//
//  AnimeItemView.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

import Kingfisher
import UIKit

final class AnimeItemView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration: configuration)
        }
    }
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let rankLabel = UILabel()
    private let typeLabel = UILabel()
    private let dateLabel = UILabel()
    private let addToFavoriteButton = UIButton(type: .custom)
    
    private var addToFavoriteHandler: AnimeItemConfiguration.AddToFavoriteHandler?
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        
        super.init(frame: .zero)
        
        directionalLayoutMargins = .init(top: 8, leading: 12, bottom: 8, trailing: 16)
        
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        
        rankLabel.font = .preferredFont(forTextStyle: .title1)
        rankLabel.textColor = .secondaryLabel
        rankLabel.textAlignment = .center
        rankLabel.adjustsFontSizeToFitWidth = true
        
        titleLabel.numberOfLines = 0
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .systemPink
        
        typeLabel.font = .preferredFont(forTextStyle: .caption1)
        typeLabel.textColor = .secondaryLabel

        dateLabel.font = .preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel
        
        addToFavoriteButton.tintColor = .systemPink
        addToFavoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        addToFavoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        addToFavoriteButton.setImage(UIImage(systemName: "heart.fill"), for: [.selected, .highlighted])
        
        addToFavoriteButton.addAction(UIAction { [unowned self] _ in
            let isFavorite = !addToFavoriteButton.isSelected
            addToFavoriteHandler?(isFavorite)
        }, for: .primaryActionTriggered)
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, typeLabel, dateLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 4
        
        let itemStack = UIStackView(arrangedSubviews: [imageView, textStack])
        itemStack.axis = .horizontal
        itemStack.alignment = .top
        itemStack.spacing = 8
        
        let mainStack = UIStackView(arrangedSubviews: [rankLabel, itemStack, addToFavoriteButton])
        mainStack.axis = .horizontal
        mainStack.alignment = .center
        mainStack.spacing = 8
        
        addAutoLayoutSubviews([mainStack])
                
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            mainStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            mainStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            mainStack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).priority(.required - 1),
            
            rankLabel.widthAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 320/225),
        ])
        
        configure(configuration: configuration)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(configuration: UIContentConfiguration) {
        guard let configuration = configuration as? AnimeItemConfiguration else {
            return
        }

        imageView.kf.setImage(with: configuration.imageURL)
        rankLabel.text = "\(configuration.rank)"
        titleLabel.text = configuration.title
        dateLabel.text = configuration.dateText
        typeLabel.text = configuration.type
        addToFavoriteButton.isSelected = configuration.isFavorite
        rankLabel.isHidden = configuration.isFavoriteListCell
        addToFavoriteButton.isHidden = configuration.isFavoriteListCell
        
        addToFavoriteHandler = configuration.addToFavoriteHandler
    }
}

struct AnimeItemConfiguration: UIContentConfiguration {
    
    var imageURL: URL?
    var title: String
    var rank: Int
    var dateText: String
    var type: String
    var isFavorite: Bool
    var isFavoriteListCell: Bool = false
    
    typealias AddToFavoriteHandler = (_ favorite: Bool) -> Void
    var addToFavoriteHandler: AddToFavoriteHandler?
    
    
    func makeContentView() -> UIView & UIContentView {
        AnimeItemView(self)
    }
    
    func updated(for state: UIConfigurationState) -> AnimeItemConfiguration {
        self
    }
}
