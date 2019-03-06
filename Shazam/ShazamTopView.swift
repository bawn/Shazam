//
//  ShazamTopView.swift
//  Shazam
//
//  Created by bawn on 2019/1/24.
//  Copyright © 2019 bawn. All rights reserved.
//

import UIKit
import SnapKit

public class ShazamTopView: UIView {
    let headerContentView = UIView()
    let menuContentView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        snp.makeConstraints { (make) in
            make.height.equalTo(0)
        }
        
        
        addSubview(headerContentView)
        headerContentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(0)
        }
        
        addSubview(menuContentView)
        menuContentView.snp.makeConstraints { (make) in
            make.top.equalTo(headerContentView.snp.bottom)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0)
        }
    }
    
    func updateLayout(_ headerViewHeight: CGFloat, _ menuViewHeight: CGFloat) {
        
        headerContentView.snp.updateConstraints { (make) in
            make.height.equalTo(headerViewHeight)
        }
        
        menuContentView.snp.updateConstraints { (make) in
            make.height.equalTo(menuViewHeight)
        }
        
        snp.updateConstraints { (make) in
            make.height.equalTo(headerViewHeight + menuViewHeight)
        }
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
        for item in frames {
            let value = item.contains(point)
            return value
        }
        return false
    }
}
