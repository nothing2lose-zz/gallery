//
//  KeyboardResignAccessoryView.swift
//  gallery
//
//  Created by nothing on 9/3/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

final class KeyboardResignAccessoryView: UIToolbar {
    
    weak var textfield: UITextField? {
        didSet {
            textfield?.inputAccessoryView = self
        }
    }
    weak var textView: UITextView? {
        didSet {
            textView?.inputAccessoryView = self
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
    
    @objc private func resignKeyboard() {
        textfield?.resignFirstResponder()
        textView?.resignFirstResponder()
    }
    
    private func setup() {
        frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let resignButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(resignKeyboard))
        setItems([flexibleSpace, resignButton], animated: true)
        
        
        
    }
    
    
    
}
