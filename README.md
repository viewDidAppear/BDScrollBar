# BDScrollBar
An old-style scroll bar for modern iOS apps.

![bdscrollbar](https://user-images.githubusercontent.com/2734719/168598673-09fe31b7-1fdf-4cff-a8a7-635a0d3abe44.png)


[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](https://raw.githubusercontent.com/viewDidAppear/BDScrollView/master/LICENSE)
[![Platform](https://img.shields.io/cocoapods/p/BDScrollBar.svg?style=for-the-badge)](http://cocoadocs.org/docsets/BDScrollBar)
[![CocoaPods](https://img.shields.io/badge/pods-BDScrollBar-brightgreen?maxAge=3600&style=for-the-badge)](https://cocoapods.org/pods/BDScrollBar)
[![Twitter](https://img.shields.io/badge/twitter-follow%20me-ff69b4?style=for-the-badge)](https://twitter.com/viewDidAppear)

---

`BDScrollBar` is a "Classic macOS" inspired UI component, which can be added to `UIScrollView` instances. Why? Because! That's why!
It is as performant as possible, but serves no real purpose other than to be as unfashionable as possible. Have fun!

* It also includes a modern style so it has a LITTLE BIT more usefulness.

# Features

* Finely scroll the entire content.
* Hooks into `UIScrollView` via KVO and the Obj-C Runtime.
* Animates like the standard scroll indicators - including bounce!
  * Turn off the bounce for added vintage effect!
* Tap the scroll bar track to jump down the content.
* Supports the "Taptic" feedback engine.

# Usage

`BDScrollBar` adds itself directly to the scroll view. It will not appear above or below. 🙌

```swift

// Make
let scrollBar = BDScrollBar()

// Add
tableView.bd_addScrollBar(scrollBar)

// Adjust right edge
tableView.separatorInset = scrollBar.adjustedSeparatorInsets(for: self.tableView.separatorInset)
```

The separator insets and the layout margins of the table view can be adjusted so nothing underlaps the scroll bar.

# Installation & Compatibility

`BDScrollBar` will work with iOS 15 and above. It supports Swift **only**.

## Manual (aka Tried & True)

Download the repo and add it into your Xcode project.

## CocoaPods

```ruby
pod 'BDScrollBar'
```

# Why? WHY?

No reason. Have fun!

# Credits

`BDScrollBar` was created by [Benjamin Deckys](https://github.com/viewDidAppear)

# License

`BDScrollBar` is available under the MIT license. Please see the [LICENSE](LICENSE) file for more information.
