//
//  AnimeItemView.swift
//  GogoAnime
//
//  Created by Tommy Lin on 2022/3/6.
//

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
    
    private let rankLayoutGuide = UILayoutGuide()
    
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
        
        let textStack = UIStackView(arrangedSubviews: [titleLabel, typeLabel, dateLabel])
        textStack.axis = .vertical
        textStack.alignment = .leading
        textStack.spacing = 4
        
        let stack = UIStackView(arrangedSubviews: [imageView, textStack])
        stack.axis = .horizontal
        stack.alignment = .top
        stack.spacing = 8
        
        addLayoutGuide(rankLayoutGuide)
        addAutoLayoutSubviews([rankLabel, stack])
        
        NSLayoutConstraint.activate([
            rankLayoutGuide.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            rankLayoutGuide.widthAnchor.constraint(equalToConstant: 40),
            
            rankLabel.leadingAnchor.constraint(equalTo: rankLayoutGuide.leadingAnchor),
            rankLabel.centerYAnchor.constraint(equalTo: layoutMarginsGuide.centerYAnchor),
            rankLabel.trailingAnchor.constraint(equalTo: rankLayoutGuide.trailingAnchor),
            
            stack.leadingAnchor.constraint(equalToSystemSpacingAfter: rankLayoutGuide.trailingAnchor, multiplier: 1.0),
            stack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor).priority(.required - 1),
            
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

        rankLabel.text = "\(configuration.rank)"
        titleLabel.text = configuration.title
        dateLabel.text = configuration.dateText
        typeLabel.text = configuration.type
    }
}

struct AnimeItemConfiguration: UIContentConfiguration {
    
    var imageURL: URL?
    var title: String
    var rank: Int
    var dateText: String
    var type: String
    
    func makeContentView() -> UIView & UIContentView {
        AnimeItemView(self)
    }
    
    func updated(for state: UIConfigurationState) -> AnimeItemConfiguration {
        self
    }
}
