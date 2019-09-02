//
//  ShazamPageViewController.swift
//  Shazam
//
//  Created by bawn on 2018/12/7.
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
import SnapKit

private enum ScrollDirection {
    case up
    case down
    case none
}


protocol AMPageControllerDataSource: class {
    
    func pageController(_ pageController: ShazamPageViewController, viewControllerAt index: Int) -> (UIViewController & ShazamChildViewController)
    func numberOfViewControllers(in pageController: ShazamPageViewController) -> Int
    func headerViewFor(_ pageController: ShazamPageViewController) -> UIView & ShazamHeaderView
    func headerViewHeightFor(_ pageController: ShazamPageViewController) -> CGFloat
    func menuViewFor(_ pageController: ShazamPageViewController) -> UIView
    func menuViewHeightFor(_ pageController: ShazamPageViewController) -> CGFloat
    func menuViewPinHeightFor(_ pageController: ShazamPageViewController) -> CGFloat
    func originIndexFor(_ pageController: ShazamPageViewController) -> Int
    func keepChildScrollViewOffset(_ pageController: ShazamPageViewController) -> Bool
}

protocol AMPageControllerDelegate: class {
    
    /// Any offset changes in pageController's mainScrollView
    ///
    /// - Parameters:
    ///   - pageController: ShazamPageViewController
    ///   - scrollView: mainScrollView
    func pageController(_ pageController: ShazamPageViewController, mainScrollViewDidScroll scrollView: UIScrollView)
    
    
    /// Method call when mainScrollView did end scroll
    ///
    /// - Parameters:
    ///   - pageController: ShazamPageViewController
    ///   - scrollView: mainScrollView
    func pageController(_ pageController: ShazamPageViewController, mainScrollViewDidEndScroll scrollView: UIScrollView)
    
    
    /// Any offset changes in pageController's childScrollView
    ///
    /// - Parameters:
    ///   - pageController: ShazamPageViewController
    ///   - scrollView: childScrollView
    func pageController(_ pageController: ShazamPageViewController, childScrollViewDidScroll scrollView: UIScrollView)
    
    /// Method call when viewController will cache
    ///
    /// - Parameters:
    ///   - pageController: ShazamPageViewController
    ///   - viewController: target viewController
    ///   - index: target viewController's index
    func pageController(_ pageController: ShazamPageViewController, willCache viewController: (UIViewController & ShazamChildViewController), forItemAt index: Int)
    
    
    /// Method call when viewController will display
    ///
    /// - Parameters:
    ///   - pageController: ShazamPageViewController
    ///   - viewController: target viewController
    ///   - index: target viewController's index
    func pageController(_ pageController: ShazamPageViewController, willDisplay viewController: (UIViewController & ShazamChildViewController), forItemAt index: Int)
    
    
    /// Method call when viewController did display
    ///
    /// - Parameters:
    ///   - pageController: ShazamPageViewController
    ///   - viewController: target viewController
    ///   - index: target viewController's index
    func pageController(_ pageController: ShazamPageViewController, didDisplay viewController: (UIViewController & ShazamChildViewController), forItemAt index: Int)
    
    
    
    /// Method call when menuView is adsorption
    ///
    /// - Parameters:
    ///   - pageController: ShazamPageViewController
    ///   - offset: offset
    ///   - isAdsorption: isAdsorption
    func pageController(_ pageController: ShazamPageViewController, headerView offset: CGPoint
        , isAdsorption: Bool)
}


open class ShazamPageViewController: UIViewController, AMPageControllerDataSource, AMPageControllerDelegate {
    
    public private(set) var currentViewController: (UIViewController & ShazamChildViewController)?
    public private(set) var currentIndex = 0
    private var originIndex = 0
    
    lazy public private(set) var mainScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.delegate = self
        scrollView.scrollsToTop = true
        scrollView.backgroundColor = .white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        if let popGesture = navigationController?.interactivePopGestureRecognizer {
            scrollView.panGestureRecognizer.require(toFail: popGesture)
        }
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        return stackView
    }()
    
    public let topView = ShazamTopView()
    private var headerViewHeight: CGFloat = 0.0
    private var menuViewHeight: CGFloat = 0.0
    private var menuViewPinHeight: CGFloat = 0.0
    private var sillValue: CGFloat = 0.0
    private var childControllerCount = 0
    private var headerView: UIView?
    private var menuView: UIView?
    private var countArray = [Int]()
    private var containViews = [ShazamContainView]()
    private var currentChildScrollView: UIScrollView?
    private var childScrollViews = [UIScrollView]()
    private var isBeginDragging = false
    
    private var topViewLastOffset: CGFloat = 0.0
    private var childScrollDirection = ScrollDirection.none
    private var isSpecialState = false
    private var childScrollViewObservation: NSKeyValueObservation?
    
    private var childScrollOffset: CGFloat = 0.0 {
        didSet {
            if oldValue > childScrollOffset {
                childScrollDirection = .down
            } else if oldValue < childScrollOffset {
                childScrollDirection = .up
            } else {
                childScrollDirection = .none
            }
        }
    }
    
    private let memoryCache = NSCache<NSString, UIViewController>()
    private weak var dataSource: AMPageControllerDataSource?
    private weak var delegate: AMPageControllerDelegate?
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        dataSource = self
        delegate = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        dataSource = self
        delegate = self
    }
    
    deinit {
        childScrollViewObservation?.invalidate()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            mainScrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        obtainDataSource()
        setupOriginContent()
        setupDataSource()
        view.layoutIfNeeded()
        
        if originIndex > 0 {
            setSelect(index: originIndex, animation: false)
        } else {
            showChildViewContoller(at: originIndex)
            didDisplayViewController(at: originIndex)
        }
    }
        
    private func didDisplayViewController(at index: Int) {
        guard childControllerCount > 0
            , index >= 0
            , index < childControllerCount
            , containViews.isEmpty == false else {
                return
        }
        let containView = containViews[index]
        currentViewController = containView.viewController
        currentChildScrollView = currentViewController?.shazamChildScrollView()
        currentIndex = index
        
        if let viewController = containView.viewController {
            pageController(self, didDisplay: viewController, forItemAt: index)
        }
    }
    
    
    private func obtainDataSource() {
        originIndex = originIndexFor(self)
        
        headerView = headerViewFor(self)
        headerViewHeight = headerViewHeightFor(self)
        
        menuView = menuViewFor(self)
        menuViewHeight = menuViewHeightFor(self)
        menuViewPinHeight = menuViewPinHeightFor(self)
        
        childControllerCount = numberOfViewControllers(in: self)
        
        sillValue = headerViewHeight - menuViewPinHeight
        countArray = Array(stride(from: 0, to: childControllerCount, by: 1))
    }
    
    
    private func setupOriginContent() {
        
        view.addSubview(mainScrollView)
        mainScrollView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        mainScrollView.addSubview(contentStackView)
        
        contentStackView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
            make.height.equalToSuperview()
        }
        
        view.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.top)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        topView.updateLayout(headerViewHeight, menuViewHeight)
    }
    
    
    private func updateOriginContent() {
        topView.updateLayout(headerViewHeight, menuViewHeight)
    }
    
    private func clear() {
        originIndex = 0
        
        childControllerCount = 0
        
        currentViewController = nil
        currentChildScrollView = nil
        
        headerView?.removeFromSuperview()
        mainScrollView.setContentOffset(.zero, animated: false)
        
        contentStackView.arrangedSubviews.forEach({$0.removeFromSuperview()})
        memoryCache.removeAllObjects()
        
        containViews.forEach({$0.viewController?.clearFromParent()})
        containViews.removeAll()
    }
    
    func setupDataSource() {
        memoryCache.countLimit = childControllerCount
        
        if let headerView = headerView {
            topView.headerContentView.addSubview(headerView)
            headerView.snp.makeConstraints({$0.edges.equalToSuperview()})
        }
        
        if let menuView = menuView {
            topView.menuContentView.addSubview(menuView)
            menuView.snp.makeConstraints({$0.edges.equalToSuperview()})
        }
        
        countArray.forEach { (_) in
            let containView = ShazamContainView()
            contentStackView.addArrangedSubview(containView)
            containView.snp.makeConstraints({ (make) in
                make.width.equalTo(view)
                make.height.equalToSuperview()
            })
            containViews.append(containView)
        }
    }
    
    func showChildViewContoller(at index: Int) {
        guard childControllerCount > 0
            , index >= 0
            , index < childControllerCount
            , containViews.isEmpty == false else {
                return
        }
        
        let containView = containViews[index]
        
        guard containView.isEmpty else {
            return
        }
        
        let cachedViewContoller = memoryCache[index] as? (UIViewController & ShazamChildViewController)
        let viewController = cachedViewContoller != nil ? cachedViewContoller : pageController(self, viewControllerAt: index)
        
        guard let targetViewController = viewController else {
            return
        }
        pageController(self, willDisplay: targetViewController, forItemAt: index)
        
        targetViewController.beginAppearanceTransition(true, animated: false)
        addChild(targetViewController)
        containView.addSubview(targetViewController.view)
        targetViewController.view.snp.makeConstraints({$0.edges.equalToSuperview()})
        targetViewController.view.layoutIfNeeded()
        targetViewController.didMove(toParent: self)
        targetViewController.endAppearanceTransition()
        
        containView.viewController = targetViewController
        
        let scrollView = targetViewController.shazamChildScrollView()
        scrollView.sz_lastOffsetY = scrollView.contentOffset.y
        
        childScrollViewObservation?.invalidate()
        let keyValueObservation = scrollView.observe(\.contentOffset, options: [.new, .old], changeHandler: { [weak self] (scrollView, change) in
            guard let self = self, change.newValue != change.oldValue else {
                return
            }
            self.childScrollViewDidScroll(scrollView)
        })
        childScrollViewObservation = keyValueObservation
        
        if scrollView.contentOffset.y <= sillValue {
            scrollView.setContentOffset(CGPoint(x: 0, y: -topView.frame.origin.y), animated: false)
        } else if keepChildScrollViewOffset(self) == false && abs(topView.frame.origin.y) < sillValue {
            scrollView.setContentOffset(CGPoint(x: 0, y: -topView.frame.origin.y), animated: false)
        }
        childScrollOffset = scrollView.contentOffset.y
        topViewLastOffset = -topView.frame.origin.y
        let offsetY = scrollView.contentOffset.y
        isSpecialState = keepChildScrollViewOffset(self) && offsetY > abs(topView.frame.origin.y)
    }
    
    
    func removeChildViewController(at index: Int) {
        guard childControllerCount > 0
            , index >= 0
            , index < childControllerCount
            , containViews.isEmpty == false else {
                return
        }
        
        let containView = containViews[index]
        guard containView.isEmpty == false
            , let viewController = containView.viewController else {
                return
        }
        viewController.clearFromParent()
        
        if memoryCache[index] == nil {
            pageController(self, willCache: viewController, forItemAt: index)
            memoryCache[index] = viewController // 缓存VC
        }
    }
    
    func layoutChildViewControlls() {
        countArray.forEach { (index) in
            let containView = containViews[index]
            let isDisplaying = containView.displayingIn(view: view, containView: mainScrollView)
            isDisplaying ? showChildViewContoller(at: index) : removeChildViewController(at: index)
        }
    }
    
    public func setSelect(index: Int, animation: Bool) {
        let offset = CGPoint(x: mainScrollView.bounds.width * CGFloat(index), y: mainScrollView.contentOffset.y)
        mainScrollView.setContentOffset(offset, animated: animation)
        if animation == false {
            mainScrollViewDidEndScroll(mainScrollView)
        }
    }
    
    private func mainScrollViewDidEndScroll(_ scrollView: UIScrollView) {
        let scrollViewWidth = scrollView.bounds.width
        guard scrollViewWidth > 0 else {
            return
        }
        
        let offsetX = scrollView.contentOffset.x
        let index = Int(offsetX / scrollViewWidth)
        didDisplayViewController(at: index)
        pageController(self, mainScrollViewDidEndScroll: mainScrollView)
    }
    
    public func reloadData() {
        mainScrollView.isUserInteractionEnabled = false
        clear()
        obtainDataSource()
        updateOriginContent()
        setupDataSource()
        view.layoutIfNeeded()
        if originIndex > 0 {
            setSelect(index: originIndex, animation: false)
        } else {
            showChildViewContoller(at: originIndex)
            didDisplayViewController(at: originIndex)
        }
        mainScrollView.isUserInteractionEnabled = true
    }
    
    open func pageController(_ pageController: ShazamPageViewController, viewControllerAt index: Int) -> (UIViewController & ShazamChildViewController) {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return UIViewController() as! UIViewController & ShazamChildViewController
    }
    
    open func numberOfViewControllers(in pageController: ShazamPageViewController) -> Int {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return 0
    }
    
    open func headerViewFor(_ pageController: ShazamPageViewController) -> UIView & ShazamHeaderView {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return UIView() as! UIView & ShazamHeaderView
    }
    
    open func headerViewHeightFor(_ pageController: ShazamPageViewController) -> CGFloat {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return 0
    }
    
    open func menuViewFor(_ pageController: ShazamPageViewController) -> UIView {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return UIView()
    }
    
    open func menuViewHeightFor(_ pageController: ShazamPageViewController) -> CGFloat {
        assertionFailure("Sub-class must implement the AMPageControllerDataSource method")
        return 0
    }
    
    open func originIndexFor(_ pageController: ShazamPageViewController) -> Int {
        return 0
    }
    
    open func menuViewPinHeightFor(_ pageController: ShazamPageViewController) -> CGFloat {
        return 0
    }
    
    open func keepChildScrollViewOffset(_ pageController: ShazamPageViewController) -> Bool {
        return false
    }
    
    open func pageController(_ pageController: ShazamPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
    }
    
    
    open func pageController(_ pageController: ShazamPageViewController, mainScrollViewDidEndScroll scrollView: UIScrollView) {
        
    }
    
    open func pageController(_ pageController: ShazamPageViewController, childScrollViewDidScroll scrollView: UIScrollView) {
        
    }
    
    open func pageController(_ pageController: ShazamPageViewController, willCache viewController: (UIViewController & ShazamChildViewController), forItemAt index: Int) {
        
    }
    
    open func pageController(_ pageController: ShazamPageViewController, willDisplay viewController: (UIViewController & ShazamChildViewController), forItemAt index: Int) {
        
    }
    
    open func pageController(_ pageController: ShazamPageViewController, didDisplay viewController: (UIViewController & ShazamChildViewController), forItemAt index: Int) {
        
    }
    
    open func pageController(_ pageController: ShazamPageViewController, headerView offset: CGPoint, isAdsorption: Bool) {
        
    }
}


extension ShazamPageViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageController(self, mainScrollViewDidScroll: scrollView)
        layoutChildViewControlls()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isBeginDragging = true
    }
    
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if decelerate == false {
            mainScrollViewDidEndScroll(mainScrollView)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if isBeginDragging {
            mainScrollViewDidEndScroll(scrollView)
            isBeginDragging = false
        }
    }
    
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        mainScrollViewDidEndScroll(scrollView)
    }
    
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard scrollView == mainScrollView else {
            return false
        }
        currentChildScrollView?.setContentOffset(.zero, animated: true)
        return true
    }
    
}

extension ShazamPageViewController {
    private func childScrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let offsetY = scrollView.contentOffset.y
        childScrollOffset = offsetY
        if isSpecialState {
            isSpecialState = offsetY > topViewLastOffset
            
            let value = offsetY - scrollView.sz_lastOffsetY
            let offset = min(value + topViewLastOffset, sillValue)
            if childScrollDirection == .up {
                topView.snp.updateConstraints { (make) in
                    make.top.equalTo(topLayoutGuide.snp.top).offset(-offset)
                }
            } else {
                topViewLastOffset = -(topView.frame.origin.y)
                scrollView.sz_lastOffsetY = offsetY
            }
        }  else {
            
            scrollView.sz_lastOffsetY = 0
            let offset = min(offsetY, sillValue)
            topView.snp.updateConstraints { (make) in
                make.top.equalTo(topLayoutGuide.snp.top).offset(-offset)
            }
        }
        let isAdsorption = abs(topView.frame.origin.y) == sillValue
        pageController(self, headerView: topView.frame.origin, isAdsorption: isAdsorption)
        pageController(self, childScrollViewDidScroll: scrollView)
    }
}
