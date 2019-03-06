# Shazam

![License MIT](https://img.shields.io/dub/l/vibe-d.svg)
![Pod version](http://img.shields.io/cocoapods/v/Shazam.svg?style=flat)
![Platform info](http://img.shields.io/cocoapods/p/LCNetwork.svg?style=flat)
[![Support](https://img.shields.io/badge/support-iOS9.0+-blue.svg?style=flat)](https://www.apple.com/nl/ios/)
[![Swift 4.2](https://camo.githubusercontent.com/cc157628e33009bbb18f6e476955a0f641f407d9/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f53776966742d342e322d6f72616e67652e7376673f7374796c653d666c6174)](https://developer.apple.com/swift/)

A pure-Swift library for nested display of horizontal and vertical scrolling views.

![demo](./demo.gif)

## Requirements

- iOS 9.0+ 
- Swift 4.2+
- Xcode 10+



## Installation

#### [CocoaPods](http://cocoapods.org/) (recommended)

```
use_frameworks!

pod 'Shazam'
```

## Usage

[中文文档](https://github.com/bawn/Shazam/blob/master/README-CHINESE.md)

First make sure to import the framework:

```
import Shazam
```

Basically, we just need to provide the list of child view controllers to show. Then call some necessary methods.

Let's see the steps to do this:

#### Create a ShazamPageViewController subclass

```swift
import Shazam

class PageViewController: ShazamPageViewController {
  // ...
}
```

#### Provide the view controllers that will appear embedded into the ShazamPageViewController

```swift
override func numberOfViewControllers(in pageController: ShazamPageViewController) -> Int {
    return count
}
    
override func pageController(_ pageController: ShazamPageViewController, viewControllerAt index: Int) -> (UIViewController & ShazamChildViewController) {
    // ...
    return viewController
}
    
```

Every UIViewController that will appear within the ShazamPageViewController should conform to `ShazamChildViewController` by implementing `func shazamChildScrollView() -> UIScrollView` 

```swift
import Shazam
class ChildViewController: UIViewController, ShazamChildViewController {

    @IBOutlet weak var tableView: UITableView!
    func shazamChildScrollView() -> UIScrollView {
        return tableView
    }
    // ...
}
```



#### Provide the headerView and headerView height 

```swift
override func headerViewFor(_ pageController: ShazamPageViewController) -> UIView & ShazamHeaderView {
    return HeaderView()
}

override func headerViewHeightFor(_ pageController: ShazamPageViewController) -> CGFloat {
    return headerViewHeight
}
```

The headerView should conform to `ShazamHeaderView` by implementing `func userInteractionViews() -> [UIView]?`

```swift
func userInteractionViews() -> [UIView]? {
    return [button]
}
```

#### Provide the menuView and menuView height

```swift
override func menuViewFor(_ pageController: ShazamPageViewController) -> UIView {
    return menuView
}

override func menuViewHeightFor(_ pageController: ShazamPageViewController) -> CGFloat {
    return menuViewHeight
}
```

#### Update menuView's layout when main scroll view did scroll and check state when did end scoll

```swift
override func pageController(_ pageController: ShazamPageViewController, mainScrollViewDidScroll scrollView: UIScrollView) {
    menuView.updateLayout(scrollView)
}

override func pageController(_ pageController: ShazamPageViewController,
                                 mainScrollViewDidEndScroll scrollView: UIScrollView) {
    menuView.checkState()
}
```



## Examples

Follow these 4 steps to run Example project: 

1. Clone Shazam repository
2. Run the `pod install` command 
3. Open Shazam workspace 
4. Run the Shazam-Demo project.

### License

Shazam is released under the MIT license. See LICENSE for details.
