//
//  SegmentedControl.swift
//  Reading Tracker
//
//  Created by Andrei Kirilenko on 01/12/2018.
//  Copyright © 2018 Andrei Kirilenko. All rights reserved.
//

import UIKit

final class SegmentedControl: UIView {
    var didSelectSegmentItem: ((Int) -> Void)?
    
    private var stackView: UIView?
    private var segments: [SegmentView] = []
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public methods
    
    func setSegments(items: [String]) {
        
        stackView?.removeFromSuperview()
        
        segments = items.map { item in
            let segmentView = SegmentView(withTitle: item)
            
            let tapGR = UITapGestureRecognizer(target: self, action: #selector(didPressButton))
            self.addGestureRecognizer(tapGR)
            segmentView.addGestureRecognizer(tapGR)
            return segmentView
        }
        
        stackView = createStackView(subviews: segments)
        addSubview(stackView!)
        stackView!.autoPinEdgesToSuperviewEdges()
    }
    
    func setSelected(index: Int) {
        segments.enumerated().forEach {
            $1.setSelected($0 == index)
        }
    }
    
    @objc private func didPressButton(sender: UITapGestureRecognizer) {
        guard let segmentView = sender.view,
            let index = segments.index(where: { $0 === segmentView }) else { return }
        
        didSelectSegmentItem?(index)
    }
    
    private func createStackView(subviews: [UIView]) -> UIView {
        let stackView = UIView()
        
        let widthMultiplier = 1.0 / CGFloat(subviews.count)
        
        subviews.enumerated().forEach { (index, view) in
            stackView.addSubview(view)
            
            if index > 0 {
                view.autoPinEdge(.left, to: .right, of: subviews[index - 1])
            } else {
                view.autoPinEdge(toSuperviewEdge: .left)
            }
            
            view.autoPinEdge(toSuperviewEdge: .top)
            view.autoPinEdge(toSuperviewEdge: .bottom)
            view.autoMatch(.width, to: .width, of: stackView, withMultiplier: widthMultiplier)
        }
        
        return stackView
    }
}

final class SegmentView: UIView {

    private let underscoreView: UIView
    private let titleLabel: UILabel
    
    init(withTitle title: String) {
        underscoreView = UIView()
        titleLabel = UILabel()
        super.init(frame: CGRect())
        
        setupSubviews()
        setSelected(false)
        setTitle(title)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubview(titleLabel)
        titleLabel.autoCenterInSuperview()
        
        underscoreView.backgroundColor = UIColor(rgb: 0x2f5870)
        addSubview(underscoreView)
        underscoreView.autoMatch(.width, to: .width, of: self)
        underscoreView.autoPinEdgesToSuperviewEdges(with: .zero, excludingEdge: .top)
        underscoreView.autoSetDimension(.height, toSize: 3)
    }
    
    func setTitle(_ title: String) {
        let textAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor(rgb: 0x2f5870),
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 18, weight: .medium)]
            as [NSAttributedString.Key : Any]
        
        titleLabel.attributedText = NSAttributedString(string: title, attributes: textAttributes)
    }
    
    func setSelected(_ selected: Bool) {
        underscoreView.isHidden = !selected
    }
}
