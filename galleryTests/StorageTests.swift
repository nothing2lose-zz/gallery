//
//  StorageTests.swift
//  gallery
//
//  Created by nothing on 9/3/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import XCTest

@testable import gallery
@testable import CoreStore

class StorageTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Storage.initialize()
        
        clearAllStorages()
    }
    
    override func tearDown() {
        super.tearDown()
//        clearAllStorages()
    }
    func clearAllStorages() {
        let exp = expectation(description: "idle")
        Storage.thumbnailImageStorage.clearDisk {}
        Storage.originalImageStorage.clearDisk {}
        Storage.deleteAllObjects {
            exp.fulfill()
        }
        wait(for: [exp], timeout: 3.0)
    }
    
    
    private func dummyImages() -> [UIImage] {
        var images = [UIImage]()
        for i in 0..<3 {
            let image = UIImage(named: "t\(i).png", in: Bundle(for: type(of: self)), compatibleWith: nil)!
            images.append(image)
        }
        return images
    }
    
    ///
    /// return `Date` by addedMonthsOffset
    ///
    private func date(with monthOffset: Int) -> Date {
        let month: TimeInterval = 60 * 60 * 24 * 30
        let offset: TimeInterval = month * Double(monthOffset)
        return Date().addingTimeInterval(offset)
    }
    
    
    
    
    func testCreateObject() {
        
        let exp = expectation(description: "create object")
        let images = dummyImages()
        
        Storage.createStory(Test.randomString(10), Test.randomString(10), images, 2) {
            XCTAssertEqual(1, Storage.numberOfStories)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    func testGroupByMonth() {
        
        let exp = expectation(description: "group shuold be a correct.")
        let images = dummyImages()
        
        Storage.createStory(Test.randomString(10), Test.randomString(10), images, 2) {
            Storage.createStory(Test.randomString(10), Test.randomString(10), images, 2, self.date(with: -2)) {
                Storage.createStory(Test.randomString(10), Test.randomString(10), images, 2, self.date(with: -2)) {
                    
                    XCTAssertEqual(3, Storage.numberOfStories)
                    
                    XCTAssertEqual(2, Storage.stories.sections().count)
                    
                    exp.fulfill()
                    
                }
            }
        }
        
        wait(for: [exp], timeout: 3.0)

    }
    
    func testImageDiskCache() {
        let exp = expectation(description: "group shuold be a correct.")
        let images = dummyImages()
        
        Storage.createStory(Test.randomString(10), Test.randomString(10), images, 2) {
            XCTAssertEqual(3, Storage.thumbnailImageStorage.getDiskCount())
            XCTAssertEqual(3, Storage.originalImageStorage.getDiskCount())
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
    }
    
    
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
