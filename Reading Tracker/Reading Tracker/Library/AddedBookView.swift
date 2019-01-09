//
//  AddedBookView.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 25/11/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import Foundation
import UIKit

class AddedBookView: UIButton {
    var imageStub: UIImageView?
    
    init(frame: CGRect, image: UIImage?) {
        super.init(frame: frame)
        
        let titleView = UILabel(forAutoLayout: ())
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870).withAlphaComponent(0.5),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14, weight: .regular)]
            as [NSAttributedString.Key : Any]
        titleView.numberOfLines = 0
        titleView.textAlignment = .center
        titleView.attributedText = NSAttributedString(string: "Обложка", attributes: textAttributes)
        
        addSubview(titleView)
        
        titleView.autoAlignAxis(toSuperviewAxis: .vertical)
        titleView.autoPinEdge(toSuperviewEdge: .top)
        
        let imageStub = UIImageView(image: image)
        imageStub.contentMode = .scaleAspectFit
        addSubview(imageStub)
        
        imageStub.autoAlignAxis(toSuperviewAxis: .vertical)
        imageStub.autoPinEdge(.top, to: .bottom, of: titleView, withOffset: 4)
        imageStub.autoSetDimensions(to: CGSize(width: 155, height: 222))
        self.imageStub = imageStub
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
