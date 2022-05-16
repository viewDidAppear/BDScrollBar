//
//  BDScrollBarGestureRecognizer.swift
//  BDScrollBar
//
//  Created by Benjamin Deckys on 2022/05/15.
//

import UIKit.UIGestureRecognizer

public final class BDScrollBarGestureRecognizer: UIGestureRecognizer {

	/** The scroll bar with this gesture.
		このジェスチャーを持ちスクロールバー
	 */
	private let scrollBar: BDScrollBar!

	public init(target: Any?, action: Selector?, scrollBar: BDScrollBar) {
		self.scrollBar = scrollBar
		super.init(target: target, action: action)
	}

	// MARK: - Internal | 非公開のfunction

	public override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
		preventedGestureRecognizer.view == scrollBar.scrollView
	}

}

// MARK: - Touch Handling | タッチ管理

public extension BDScrollBarGestureRecognizer {
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		state = .began
	}

	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
		state = .changed
	}

	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		state = .ended
	}

	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
		state = .cancelled
	}
}
