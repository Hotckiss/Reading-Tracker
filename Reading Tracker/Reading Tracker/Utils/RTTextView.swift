//
//  RTTextView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 24.09.2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit

public final class RTTextField: UITextField {
    
    private let padding: UIEdgeInsets
    
    public init(frame: CGRect = .zero, padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)) {
        self.padding = padding
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}
