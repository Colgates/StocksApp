//
//  NewsStoryTableViewCell.swift
//  StocksApp
//
//  Created by Evgenii Kolgin on 27.01.2022.
//

import SDWebImage
import UIKit

class NewsStoryTableViewCell: UITableViewCell {

    static let identifier = "NewsStoryTableViewCell"
    
    static let preferredHeight: CGFloat = 140
    
    struct ViewModel {
        let source: String
        let headline: String
        let dateString: String
        let imageURL: URL?
        
        init(model: NewsStory) {
            self.source = model.source
            self.headline = model.headline
            self.dateString = .string(from: model.datetime)
            self.imageURL = URL(string: model.image)
        }
    }
    
    private let sourceLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        contentView.addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        NSLayoutConstraint.activate([
            sourceLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            sourceLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            sourceLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            sourceLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.2),
            
            headlineLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            headlineLabel.topAnchor.constraint(equalTo: sourceLabel.bottomAnchor, constant: 5),
            headlineLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            headlineLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.5),
            
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
            dateLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 5),
            dateLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            storyImageView.leadingAnchor.constraint(equalTo: sourceLabel.trailingAnchor),
            storyImageView.topAnchor.constraint(equalTo: sourceLabel.topAnchor),
            storyImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            storyImageView.bottomAnchor.constraint(equalTo: dateLabel.bottomAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        sourceLabel.text = nil
        headlineLabel.text = nil
        dateLabel.text = nil
        storyImageView.image = nil
    }
    
    public func configure(with viewModel: ViewModel) {
        sourceLabel.text = viewModel.source
        headlineLabel.text = viewModel.headline
        dateLabel.text = viewModel.dateString
        storyImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
    }
}
