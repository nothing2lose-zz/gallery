//
//  Image.swift
//  gallery
//
//  Created by nothing on 9/2/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import CoreData

import CoreStore

///
///
///
final class Image: CoreStoreObject {
    
    let master = Relationship.ToOne<Story>("master")
    /// 
    /// `fieldId` is name of a phyical file name.
    ///
    let fileId = Value.Required<String>("fileId", initial: "undefined")
}

///
/// Helper
///
extension Image {
    // TODO: It has a performance issue.
    var thumbnailImage: UIImage? {
        return Storage.thumbnailImageStorage.imageFromCache(forKey: fileId.value)
    }
    // TODO: It has a performance issue.
    var image: UIImage? {
        return Storage.originalImageStorage.imageFromCache(forKey: fileId.value)
    }
}
