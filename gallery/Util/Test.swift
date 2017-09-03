//
//  Test.swift
//  gallery
//
//  Created by nothing on 9/3/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

class Test {
    
    static func randomString(_ length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    static func randomInt(_ min: Int, _ max: Int)-> Int {
        
        return Int(arc4random_uniform(UInt32(max)) + UInt32(min));
        
    }
}
