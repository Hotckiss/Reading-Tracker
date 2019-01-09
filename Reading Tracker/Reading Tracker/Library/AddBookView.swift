//
//  AddBookView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 25/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class AddBookView: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let titleView = UILabel(forAutoLayout: ())
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20, weight: .regular)]
            as [NSAttributedString.Key : Any]
        titleView.numberOfLines = 0
        titleView.textAlignment = .center
        titleView.attributedText = NSAttributedString(string: "Обложка", attributes: textAttributes)
        
        addSubview(titleView)
        
        titleView.autoAlignAxis(toSuperviewAxis: .vertical)
        titleView.autoPinEdge(toSuperviewEdge: .top)
        
        let imageStub = UIImageView(image: UIImage(named: "addBookStub"))
        
        addSubview(imageStub)
        
        imageStub.autoAlignAxis(toSuperviewAxis: .vertical)
        imageStub.autoPinEdge(.top, to: .bottom, of: titleView, withOffset: 4)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
