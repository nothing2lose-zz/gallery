//
//  ImageCell.swift
//  gallery
//
//  Created by nothing on 9/1/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

final class ImageCell: UICollectionViewCell {
    
    static let identifier: String = "ImageCell"
    
    private(set) var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override var reuseIdentifier: String? {
        return type(of: self).identifier
    }
    
    override var isSelected: Bool {
        didSet {
            self.layer.borderWidth = isSelected ? 3 : 0
        }
    }
    
    // MARK: - private
    private func setup() {
        
        // layout
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        // style
        self.layer.borderColor = UIColor.red.cgColor
    }
}
