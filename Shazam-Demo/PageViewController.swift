//
//  PageViewController.swift
//  Shazam-Demo
//
//  Created by bawn on 2018/12/8.
//  Copyright © 2018 bawn. All rights reserved.( http://bawn.github.io )
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Shazam

class PageViewController: ShazamPageViewController {

    let navBar = UIView()
    let headerView = HeaderView()
    let menuView = MenuView(parts:
        .normalTextColor(UIColor.gray),
        .selectedTextColor(UIColor.blue),
        .textFont(UIFont.systemFont(ofSize: 15.0)),
        .progressColor(UIColor.blue),
        .progressHeight(2)
    )
    var count = 3
    var headerViewHeight: CGFloat = 200.0
    var menuViewHeight: CGFloat = 44.0
    lazy var selectedIndex = tabBarController?.selectedIndex ?? 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        headerView.button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        
        
        if selectedIndex == 0 {
            if #available(iOS 11.0, *) {
                mainScrollView.contentInsetAdjustmentBehavior = .never
            } else {
                automaticallyAdjustsScrollViewInsets = false
            }
        }
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        navBar.alpha = 0.0
        navBar.backgroundColor = .white
        view.addSubview(navBar)
        navBar.snp.makeConstraints { (make) in
            make.leading.equalToSuperview()
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(UIApplication.shared.statusBarFrame.height + 44.0)
        }
        
        menuView.titles = ["Superman", "Batman", "WonderWoman"]
        menuView.delegate = self
    }
    
    @objc func buttonAction(_ sender: UIButton) {
        print(#function)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if selectedIndex == 0 {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    
    override func headerViewFor(_ pageController: ShazamPageViewController) -> UIView & ShazamHeaderView {
        return headerView
    }
    
    override func headerViewHeightFor(_ pageController: ShazamPageViewController) -> CGFloat {
        return headerViewHeight
    }
    
    override func numberOfViewControllers(in pageController: ShazamPageViewController) -> Int {
        return count
    }
    
    override func pageController(_ pageController: ShazamPageViewController, viewControllerAt index: Int) -> (UIViewController & ShazamChildViewController) {
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if index == 0 {
            let viewController = storyboard.instantiateViewController(withIdentifier: "SupermanViewController") as! SupermanViewController
            viewController.selectedIndex = selectedIndex
            return viewController
        } else if index == 1 {
            let viewController = storyboard.instantiateViewController(withIdentifier: "BatmanViewController") as! BatmanViewController
            viewController.selectedIndex = selectedIndex
            return viewController
        } else {
            let viewController = storyboard.instantiateViewController(withIdentifier: "WonderWomanViewController") as! WonderWomanViewController
            viewController.selectedIndex = selectedIndex
            return viewController
        }
        
    }
    
    
//    override func originIndexFor(_ pageController: ShazamPageViewController) -> Int {
//        return 2
//    }
    
    override func menuViewFor(_ pageController: ShazamPageViewController) -> UIView {
        return menuView
    }
    
    override func menuViewHeightFor(_ pageController: ShazamPageViewController) -> CGFloat {
        return menuViewHeight
    }
    
    override func menuViewPinHeightFor(_ pageController: ShazamPageViewController) -> CGFloat {
        return UIApplication.shared.statusBarFrame.height + 44.0
    }

    
    override func pageController(_ pageController: ShazamPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
        menuView.updateLayout(scrollView)
    }
    
    override func pageController(_ pageController: ShazamPageViewController,
                                 mainScrollViewDidEndScroll scrollView: UIScrollView) {
        menuView.checkState()
    }
    
    override func pageController(_ pageController: ShazamPageViewController, headerView offset: CGPoint, isAdsorption: Bool) {
        
        let rate = (UIApplication.shared.statusBarFrame.height * 3.0)
        navBar.alpha = min(-offset.y / rate, 1.0)
        navBar.backgroundColor = isAdsorption ? .blue : .white
    }
    
    override func pageController(_ pageController: ShazamPageViewController, childScrollViewDidScroll scrollView: UIScrollView) {
        if scrollView.contentOffset.y == 0 {
            navBar.alpha = 0
        }
    }

    override func keepChildScrollViewOffset(_ pageController: ShazamPageViewController) -> Bool {
        return true
    }
    
    override func pageController(_ pageController: ShazamPageViewController, willDisplay viewController: (UIViewController & ShazamChildViewController), forItemAt index: Int) {

    }
    
    override func pageController(_ pageController: ShazamPageViewController, didDisplay viewController: (UIViewController & ShazamChildViewController), forItemAt index: Int) {
    }
    
    deinit {
        print(#function)
    }
}


extension PageViewController: MenuViewDelegate {
    func menuView(_ menuView: MenuView, didSelectedItemAt index: Int) {
        guard index < count else {
            return
        }
        setSelect(index: index, animation: true)
    }
}
