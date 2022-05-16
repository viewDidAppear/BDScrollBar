//
//  UIScrollView+BDScrollbar.swift
//  BDScrollBar
//
//  Created by Benjamin Deckys on 2022/05/13.
//

import UIKit
import ObjectiveC

private var ScrollBarAssociatedHandle: UInt8 = 93

extension UIScrollView {
	var bd_scrollBar: BDScrollBar? {
		get {
			objc_getAssociatedObject(self, &ScrollBarAssociatedHandle) as? BDScrollBar
		}

		set {
			objc_setAssociatedObject(self, &ScrollBarAssociatedHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}

	func bd_addScrollBar(_ scrollBar: BDScrollBar) {
		scrollBar.add(to: self)
	}

	func bd_remove() {
		bd_scrollBar?.remove()
	}
}
