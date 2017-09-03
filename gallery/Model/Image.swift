//
//  Image.swift
//  gallery
//
//  Created by nothing on 9/2/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import CoreData

import CoreStore

final class Image: CoreStoreObject {
    let master = Relationship.ToOne<Story>("master")
    let fileId = Value.Required<String>("fileId", initial: "undefined") // TOOD: rename file key?
}

///
/// Helper
///
extension Image {
    
    var thumbnailImage: UIImage? {
        return Storage.thumbnailImageStorage.imageFromCache(forKey: fileId.value)
    }
    // TODO: It has a performance issue.
    var image: UIImage? {
        return Storage.originalImageStorage.imageFromCache(forKey: fileId.value)
    }
}
