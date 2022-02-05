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
        return label
    }()

    private let headlineLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    private let storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        backgroundColor = .secondarySystemBackground
        addSubviews(sourceLabel, headlineLabel, dateLabel, storyImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 6
        storyImageView.frame = CGRect(x: contentView.width - imageSize - 10, y: 3, width: imageSize, height: imageSize)
        
        let availableWidth: CGFloat = contentView.width - separatorInset.left - imageSize - 15
        dateLabel.frame = CGRect(x: separatorInset.left, y: contentView.height - 40, width: availableWidth, height: 40)
        sourceLabel.sizeToFit()
        sourceLabel.frame = CGRect(x: separatorInset.left, y: 4, width: availableWidth, height: sourceLabel.height)
        
        headlineLabel.frame = CGRect(x: separatorInset.left, y: sourceLabel.bottom + 5, width: availableWidth, height: contentView.height - sourceLabel.bottom - dateLabel.height - 10)
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
