//
//  ViewModelTests.swift
//  gallery
//
//  Created by nothing on 9/3/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import XCTest

@testable import gallery

class ViewModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Storage.initialize()
        
        clearAllStorages()
        
        
    }
    override func tearDown() {
        super.tearDown()
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

    
    func testStoryViewModel() {
        let exp = expectation(description: "viewModel Test")
        
        let now = Date()
        let title = Test.randomString(10)
        let content = Test.randomString(10)
        
        Storage.createStory(title, content, [], nil, now) {
            let story = Storage.stories.objectsInAllSections().first
            XCTAssertEqual(1, Storage.numberOfStories)
            XCTAssertNotNil(story)
            
            let vm = StoryViewModel(story!)
            XCTAssertEqual(title, vm.title)
            XCTAssertEqual(content, vm.content)
            
            let df = DateFormatter()
            df.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
            XCTAssertEqual(df.string(from: now), vm.modifiedDateString)
            XCTAssertEqual(0, vm.thumbnailImages.count)
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)

    }
    
    
}
