//
//  StoryDetailView.swift
//  gallery
//
//  Created by nothing on 9/1/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import UITextView_Placeholder

final class StoryDetailView: UIView {
    
    private(set) lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.itemSize = CGSize(width: 150, height: 150)
        layout.scrollDirection = .horizontal
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isDirectionalLockEnabled = true
        cv.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
        cv.delegate = self
        cv.dataSource = self
        cv.allowsMultipleSelection = false
        return cv
    }()
    
    private(set) lazy var photoCountLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()
    private(set) lazy var titleTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "제목을 입력해 주세요."
        let close = KeyboardResignAccessoryView()
        close.textfield = tf
        return tf
    }()
    private(set) lazy var descriptionTextView: UITextView = {
        let tv = UITextView()
        tv.placeholder = "내용을 입력해 주세요."
        tv.font = self.titleTextField.font
        
        let close = KeyboardResignAccessoryView()
        close.textView = tv
        return tv
    }()
    private(set) lazy var modifiedDateLabel: UILabel = {
        let lb = UILabel()
        return lb
    }()
    
    var selectedThumbnailIndex: Int?
    
    var images: [UIImage]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: - private
    private func setup() {
        
        // layout
        addSubview(photoCountLabel)
        addSubview(collectionView)
        addSubview(titleTextField)
        addSubview(descriptionTextView)
        addSubview(modifiedDateLabel)
        
        photoCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self)
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).offset(-10)
            make.height.equalTo(30)
        }
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(photoCountLabel.snp.bottom).offset(10)
            make.leading.equalTo(self)
            make.trailing.equalTo(self)
            make.height.equalTo(150)
        }
        titleTextField.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView.snp.bottom).offset(15)
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).offset(-10)
            make.height.equalTo(30)
        }
        descriptionTextView.snp.makeConstraints { (make) in
            make.top.equalTo(titleTextField.snp.bottom).offset(15)
            make.leading.equalTo(self).offset(10)
            make.height.equalTo(180)
            make.trailing.equalTo(self).offset(-10)
        }
        
        modifiedDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionTextView.snp.bottom)
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).offset(-10)
        }
    }
}

// MARK: - UICollectionView Datasource & Delegate
extension StoryDetailView: UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: datasource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let images = images else { return 0 }
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as? ImageCell else { return UICollectionViewCell() }
        cell.imageView.image = images?[indexPath.row]
        cell.isSelected = indexPath.row == selectedThumbnailIndex
        return cell
    }
    
    // MARK: delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.visibleCells.forEach { $0.isSelected = false }
        collectionView.cellForItem(at: indexPath)?.isSelected = true
        selectedThumbnailIndex = indexPath.row
    }
}
