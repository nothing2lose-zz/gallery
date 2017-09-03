//
//  StoryViewModel.swift
//  gallery
//
//  Created by nothing on 9/3/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

struct StoryViewModel {
    private var story: Story
    
    init(_ story: Story) {
        self.story = story
    }
    
    func model() -> Story {
        return story
    }
    
    var title: String {
        return story.title.value
    }

    var content: String {
        return story.descriptionText.value
    }
    
    var modifiedDateString: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        return df.string(from: story.modifiedAt.value) 
    }
    
    var modifiedDateDescriptionString: String {
        return "\(modifiedDateString)에 수정됨"
    }
    
    var selectedThumbnailIndex: Int? {
        return story.thumbnailImageIndex.value
    }
    
    var imageCountDescriptionString: String {
        let imageCount = story.images.value.count
        return "\(imageCount)장의 사진"
    }
    
    var thumbnailImage: UIImage? {
        if let thumbnailImageIndex = story.thumbnailImageIndex.value {
            return story.images[thumbnailImageIndex].thumbnailImage
        }
        return nil
    }
    
    var thumbnailImages: [UIImage] {
        return story.images.value
            .filter { nil != $0.thumbnailImage }
            .map { $0.thumbnailImage! }
    }
    
    var originalImages: [UIImage] {
        return story.images.value
            .filter { nil != $0.image }
            .map { $0.image! }
    }
}
