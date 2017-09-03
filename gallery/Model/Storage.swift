//
//  Storage.swift
//  gallery
//
//  Created by nothing on 9/2/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import CoreStore
import SDWebImage

public struct Storage {
    
    
    // MARK: - DiskCache
    static let thumbnailImageStorage: SDImageCache = {
        let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        let absolutePath = path.appendingPathComponent("gallery")
        let store = SDImageCache(namespace: "thumbnails", diskCacheDirectory: absolutePath.relativePath)
        store.config.shouldCacheImagesInMemory = false
        store.config.maxCacheAge = Int.max // persistent
        return store
    }()
    static let originalImageStorage: SDImageCache = {
        let path = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first!
        let absolutePath = path.appendingPathComponent("gallery")
        let store = SDImageCache(namespace: "originalImages", diskCacheDirectory: absolutePath.relativePath)
        store.config.shouldCacheImagesInMemory = false
        store.config.maxCacheAge = Int.max // persistent
        return store
    }()
    
    
    // MARK: -
    
    enum Filter {
        case all
        case query(query: String)
        
        func whereClause() -> Where {
            switch self {
            case .all: return Where(true)
            case .query(let query):
                let predicate = NSPredicate(format: "title CONTAINS[cd] %@", query)
                return Where(predicate)
            }
        }
    }
    
    static func initialize() {
        try! Storage.stack.addStorageAndWait(
            SQLiteStore(
                fileName: "Story.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
            )
        )        
    }

    static let stack: DataStack = {
        
        return DataStack(
            CoreStoreSchema(
                modelVersion: "Story",
                entities: [
                    Entity<Story>("Story"),
                    Entity<Image>("Image"),
                    ],
                versionLock: [
                    "Image": [0xdb6847c5f079004c, 0x45d712896cad070c, 0x144964cac033506f, 0xaee6bd38c0b7596],
                    "Story": [0x4b38d7b3d7c15006, 0xb4cb593ed9700fbc, 0x6c6ea368b63e2248, 0x92710c38de43cee4]
                ]
            )
        )
    }()
    
    static let stories: ListMonitor<Story> = {
        initialize()
        
        return Storage.stack.monitorSectionedList(
            From<Story>(),
            SectionBy(Story.keyPath({ $0.modifiedAtMonth }), { (modifiedAt) -> String? in
                return modifiedAt
            }),
            Story.orderBy(descending: { $0.modifiedAt })
        )
    }()
    static var numberOfStories: Int {
        return stories.numberOfObjects()
    }
    
    
    static func refetch() {
        let f = filter
        self.filter = f
    }
    
    static var filter: Filter = .all {
        didSet {
            self.stories.refetch(
                filter.whereClause(),
                Story.orderBy(descending: { $0.modifiedAt })
            )
        }
    }

    ///
    /// NOTE: `updateStory` currently does not support `images`.
    ///
    static func updateStory(_ story: Story, _ title: String?, _ content: String?, _ thumbnailIndex: Int?, _ modifiedAt: Date? = nil, _ completionHandler: (() -> Void)? = nil) {
        stack.perform(asynchronous: { (transaction) -> Void in
            let story = transaction.edit(story)
            if let title = title {
                story?.title .= title
            }
            if let content = content {
                story?.descriptionText .= content
            }
            story?.modifiedAt .= Date()
            story?.thumbnailImageIndex .= thumbnailIndex
            
        }) { _ in
            completionHandler?()
        }
    }
    
    static func deleteStory(_ story: Story, _ completionHandler: (() -> Void)?) {
        
        func deleteFromDB() {
            stack.perform(asynchronous: { (transaction) -> Void in                
                transaction.delete(story)
            }) { _ in
                completionHandler?()
            }
        }
        
        var imageCount = story.images.count

        // remove image from disk
        if imageCount > 0 {
            
            let fileIds = story.images.value.map { $0.fileId.value }
            fileIds.forEach {
                deleteImageFile($0, {
                    imageCount -= 1
                    
                    if imageCount == 0 {
                        deleteFromDB()
                    }
                })
            }
            
        } else {
            deleteFromDB()
        }
    }
    
    static func createStory(_ title: String?, _ content: String?, _ images: [UIImage], _ thumbnailIndex: Int?, _ modifiedAt: Date? = nil, _ completionHandler: (() -> Void)? = nil) {
        var imageFileIds: [String] = []
        var imageSaveCounter = images.count
        
        // store in db
        func saveToDB() {
            
            Storage.stack.perform(
                asynchronous: { (transaction) in
                    
                    // image
                    
                    var imageModels: [Image] = []
                    
                    for (_, v) in imageFileIds.enumerated() {
                        let image = transaction.create(Into<Image>())
                        image.fileId .= v
                        imageModels.append(image)
                    }
                    
                    // story
                    
                    let story = transaction.create(Into<Story>())
                    
                    if let title = title {
                        story.title .= title
                    }
                    if let content = content {
                        story.descriptionText .= content
                    }
                    story.modifiedAt .= Date()
                    story.createdAt .= Date()
                    story.thumbnailImageIndex .= thumbnailIndex
                    story.images .= imageModels
                    
            },
                completion: { _ in
                    completionHandler?()
            })
            
        }

        
        // store image to disk
        if imageSaveCounter > 0 {
            
            for (_, v) in images.enumerated() {
                let fileId = UUID().uuidString.lowercased()
                imageFileIds.append(fileId)
                
                saveImageFile(fileId, v) { _ in
                    imageSaveCounter -= 1
                    
                    if 0 == imageSaveCounter {
                        saveToDB()
                    }
                    
                }
            }
            
        } else {
            saveToDB()
        }
        
        
        
    }
    
    static func deleteAllObjects(_ completionHandler: @escaping (() -> Void)) {
        stack.perform(asynchronous: { (transaction) -> Void in
            transaction.deleteAll(From<Story>(), Where(true))
        }) { (_) in
            completionHandler()
        }
    }
    
    // image cache util
    
    // TODO: refactor & delete method should be implemented.
    private static func deleteImageFile(_ fileId: String, _ completionHandler: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var counter = 0
            func completed() {
                if (counter == 2) {
                    completionHandler()
                }
            }
            self.thumbnailImageStorage.removeImage(forKey: fileId, fromDisk: true, withCompletion: {
                counter += 1
                completed()
            })
            self.originalImageStorage.removeImage(forKey: fileId, fromDisk: true, withCompletion: {
                counter += 1
                completed()
            })
        }
    }
    
    private static func saveImageFile(_ fileId: String, _ image: UIImage, _ completionHandler: @escaping (() -> Void)) {
        DispatchQueue.global(qos: .background).async {
            var counter = 0
            func completed() {
                if (counter == 2) {
                    completionHandler()
                }
            }
            self.thumbnailImageStorage.store(image, imageData: UIImageJPEGRepresentation(image, 0.3), forKey: fileId, toDisk: true, completion: {
                counter += 1
                completed()
            })
            
            self.originalImageStorage.store(image, imageData: nil, forKey: fileId, toDisk: true, completion: {
                counter += 1
                completed()
            })
        }
        
        
        
//        guard let url = FileManager.default.urls(for: .documentDirectory, in: .allDomainsMask).first else {
//            // TODO: handle error
//            return
//        }
//        let absolutePath = url.appendingPathComponent(relativeFilePath).absoluteString
//        
//        do {
////            DataFile(path: <#T##Path#>)
////            try Path(absolutePath).createFile()
////            File(path: Path()).write(<#T##data: Readable & Writable##Readable & Writable#>)
//        } catch {
//            // TODO: handle error
//            print(error.localizedDescription)
//        }
        
    }
}
