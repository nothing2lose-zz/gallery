//
//  StoryCell.swift
//  gallery
//
//  Created by nothing on 9/1/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import SnapKit

final class StoryCell: UITableViewCell {
    
    static let identifier: String = "StoryCell"
    
    private lazy var thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    private lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 5
        return lb
    }()
    private lazy var descriptionLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = 20
        return lb
    }()
    
    var item: Story? {
        didSet {
            bindData()
        }
    }
    
    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    
    // MARK: - private
    private func bindData() {
        guard let item = item else { return }
        
        titleLabel.text = item.title.value
        descriptionLabel.text = item.modifiedAtDescription // item.descriptionText.value
        
        if let thumbnailImageIndex = item.thumbnailImageIndex.value {
            self.thumbnailImageView.image = item.images[thumbnailImageIndex].thumbnailImage
        } else {
            self.thumbnailImageView.image = nil
        }
    }
    
    
    private func setup() {
        
        // layout
        
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        
        thumbnailImageView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView)
            make.leading.equalTo(contentView)
            make.height.equalTo(100)
            make.width.equalTo(thumbnailImageView.snp.height)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.leading.equalTo(thumbnailImageView.snp.trailing).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(30)
        }
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(5)
            make.leading.equalTo(titleLabel)
            make.trailing.equalTo(titleLabel)
            make.bottom.equalTo(contentView)
        }
        
    }
    
    


}
