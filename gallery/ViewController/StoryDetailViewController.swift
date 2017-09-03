//
//  StoryDetailViewController.swift
//  gallery
//
//  Created by nothing on 9/1/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import CoreStore
import RxSwift
import RxCocoa

final class StoryDetailViewController: UIViewController {

    private lazy var detailView: StoryDetailView = {
        StoryDetailView()
    }()
    
    private var disposeBag = DisposeBag()
    
    var viewModel: StoryViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            
            detailView.images = viewModel.thumbnailImages
            detailView.selectedThumbnailIndex = viewModel.selectedThumbnailIndex
            detailView.titleTextField.text = viewModel.title
            detailView.descriptionTextView.text = viewModel.content
            detailView.modifiedDateLabel.text = viewModel.modifiedDateDescriptionString
            detailView.photoCountLabel.text = viewModel.imageCountDescriptionString
        }
    }
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setup()
    }
    
    
    
    // MARK: - private
    private func save() {
        
        guard let viewModel = viewModel else { return }
        
        let dv = detailView
        let title = dv.titleTextField.text
        let content = dv.descriptionTextView.text
        let selectedThumbnailIndex = dv.selectedThumbnailIndex

        // TODO: support delete images.
        
        Storage.updateStory(viewModel.model(), title, content, selectedThumbnailIndex) {
//            Storage.refetch()
            self.navigationController?.popViewController(animated: true)
        }
        
//        Storage.stack.perform(asynchronous: { (transaction) -> Void in
//            let story = transaction.edit(storyItem)
//            if let title = title {
//                story?.title .= title
//            }
//            if let content = content {
//                story?.descriptionText .= content
//            }
//            story?.modifiedAt .= Date()
//            story?.thumbnailImageIndex .= selectedThumbnailIndex
//
//        }) { _ in
//        }
        
    }
    
    private func setup() {
        
        // layout
        
        view.addSubview(detailView)
        detailView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.save()
            })
            .addDisposableTo(disposeBag)
        
        let longTapGesture = UILongPressGestureRecognizer()
        longTapGesture.rx.event
            .bind { e in
                if e.state == UIGestureRecognizerState.began {
                    self.showImagesInFullViewController(at: self.detailView.selectedThumbnailIndex ?? 0)
                }
            }
            .addDisposableTo(disposeBag)
        
        detailView.collectionView.addGestureRecognizer(longTapGesture)
        
        // style
        title = "Detail"
    }
    
}

extension StoryDetailViewController: ImagePresentableProtocol {
    
    var images: [UIImage]? {
        return viewModel?.originalImages
    }
}
