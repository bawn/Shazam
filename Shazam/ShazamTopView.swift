//
//  ShazamTopView.swift
//  Shazam
//
//  Created by bawn on 2019/1/24.
//  Copyright © 2019 bawn. All rights reserved.
//

import UIKit

public class ShazamTopView: UIView {
    let headerContentView = UIView()
    let menuContentView = UIView()
    var heightLayout: NSLayoutConstraint?
    var headerHeightLayout: NSLayoutConstraint?
    var menuHeightLayout: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        heightLayout = heightAnchor.constraint(equalToConstant: 0)
        heightLayout?.isActive = true
        
        addSubview(headerContentView)
        headerContentView.translatesAutoresizingMaskIntoConstraints = false
        headerContentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        headerContentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        headerContentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        headerHeightLayout = headerContentView.heightAnchor.constraint(equalToConstant: 0)
        headerHeightLayout?.isActive = true
        
        addSubview(menuContentView)
        menuContentView.translatesAutoresizingMaskIntoConstraints = false
        menuContentView.topAnchor.constraint(equalTo: headerContentView.bottomAnchor).isActive = true
        menuContentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        menuContentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        menuContentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        menuHeightLayout = menuContentView.heightAnchor.constraint(equalToConstant: 0)
        menuHeightLayout?.isActive = true
    }
    
    func updateLayout(_ headerViewHeight: CGFloat, _ menuViewHeight: CGFloat) {
        headerHeightLayout?.constant = headerViewHeight
        menuHeightLayout?.constant = menuViewHeight
        heightLayout?.constant = headerViewHeight + menuViewHeight
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if menuContentView.frame.contains(point) {
            return true
        }
        guard let headerView = headerContentView.subviews.first as? ShazamHeaderView
            , let userInteractionViews = headerView.userInteractionViews() else {
            return false
        }
        var frames = [CGRect]()
        userInteractionViews.forEach { (item) in
            let frame = convert(item.frame, to: self)
            frames.append(frame)
        }
        return !frames.filter({$0.contains(point)}).isEmpty
    }
}
