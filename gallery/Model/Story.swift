//
//  Story.swift
//  gallery
//
//  Created by nothing on 9/2/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import CoreData
import CoreStore

final class Story: CoreStoreObject {
    
    let title = Value.Required<String>("title", initial: "no name")
    let descriptionText = Value.Required<String>("descriptionText", initial: "no contents")
    
    
    let createdAt = Value.Required<Date>("createdAt", initial: Date())
    let modifiedAt = Value.Required<Date>("modifiedAt", initial: Date())
    ///
    /// it is only for `groupby`.
    ///
    let modifiedAtMonth = Value.Optional<String>(
	        "modifiedAtMonth",
	        isTransient: true,
	        customGetter: Story.getModifiedAtMonth
    )
    
    let thumbnailImageIndex = Value.Optional<Int>("thumbnailImageIndex", initial: nil)
    let images = Relationship.ToManyOrdered<Image>("images", inverse: { $0.master })
    
    
    private static func getModifiedAtMonth(_ partialObject: PartialObject<Story>) -> String? {
        if let modifiedAtMonth = partialObject.primitiveValue(for: { $0.modifiedAtMonth }) {
            return modifiedAtMonth
        }
        
        let date = partialObject.value(for: { $0.modifiedAt })
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM"
        return df.string(from: date)
//        let comps = Calendar.current.dateComponents([.year, .month], from: date)
//        return Calendar.current.date(from: comps)
    }
    
}

// Helper
extension Story {
    var modifiedAtDescription: String? {
        let df = DateFormatter()
        df.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
        return df.string(from: modifiedAt.value)
    }
}
