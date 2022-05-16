//
//  BDScrollBar.swift
//  BDScrollBar
//
//  Created by Benjamin Deckys on 2022/05/13.
//

import UIKit

open class BDScrollBar: UIView {

	// MARK: - Style Enum

	public enum BDScrollBarStyle {
		// 90年代のmacOSスタイル
		// Similar style to 90s macOS
		case `default`

		// ただのモダーンスタイル. システムのデフォルトとは少し異なる
		// Simple modern style. Differs slightly from the system default.
		case modern
	}

	// MARK: - Customizable Properties | 変更可能な変数

	/** スクロールバーのスタイル */
	open var style: BDScrollBarStyle = .default

	/** 大きいタイトルを使用なら、スクロールビューのオフセットに一致するようにtrueにする */
	open var insetForLargeTitles: Bool = false

	// MARK: - Non-customizable Variables | 変更不可能な変数

	/** スクロールバーの幅 */
	public var trackWidth: CGFloat {
		switch style {
			case .default:
				// 90年代のmacOSみたい
				return 20
			case .modern:
				// システムのデフォルトと同じくらい
				return 2
		}
	}

	/** スクロールハンドルの幅 */
	public var handleWidth: CGFloat {
		switch style {
			case .default:
				// 90年代のmacOSみたい
				return 20
			case .modern:
				// システムのデフォルトと同じくらい
				return 4
		}
	}

	/** 画面の端から間隔 */
	public var edgeInset: CGFloat {
		switch style {
			case .default:
				// スクロールバーがウィンドウの端に接触するはず
				return 0
			case .modern:
				// システムのデフォルトと同じくらい
				return 7.5
		}
	}

	/** スクロールバーのハンドルの最小高さ */
	public var handleMinimumHeight: CGFloat {
		switch style {
			case .default:
				return 64
			case .modern:
				return 4
		}
	}

	/** スクロールバーの下に表示さられないようにUITableViewCellの内容を左に移動する */
	public var layoutMarginRight: CGFloat {
		switch style {
			case .default:
				return 30
			case .modern:
				return edgeInset * 2
		}
	}

	/** スクロールバーの背景イメージ */
	private var trackImage: UIImage? {
		switch style {
			case .default:
				// ９０年代のmacOSスタイルならうちのアセットを使用
				return #imageLiteral(resourceName: "shp:scrollTrackImage")
			case .modern:
				// モダーンスタイルならイメージが不要
				return UIImage.imageFrom(color: trackTintColor, width: trackWidth)
		}
	}

	/** スクロールバーのハンドルイメージ */
	private var handleImage: UIImage? {
		switch style {
			case .default:
				// ９０年代のmacOSスタイルならうちのアセットを使用
				return #imageLiteral(resourceName: "shp:scrollBarImage")
			case .modern:
				// モダーンスタイルならイメージが不要
				return UIImage.imageFrom(color: handleTintColor, width: handleWidth)
		}
	}

	/** スクロールバーの上下部であるの間隔 */
	private var verticalInset: UIEdgeInsets {
		switch style {
			case .default:
				return .zero
			case .modern:
				return UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
		}
	}

	/** スクロールバーの背景色. `.modern`のみで使用 */
	private var trackTintColor: UIColor {
		// ダークモードが設定されているかのをチェック
		let userInterfaceStyleIsDark = traitCollection.userInterfaceStyle == .dark

		// ダークモードならホワイトを、それともライトモードならブラックを
		let whiteValue: CGFloat = userInterfaceStyleIsDark ? 1.0 : 0.0

		switch style {
			case .default:
				return .white
			case .modern:
				return UIColor(white: whiteValue, alpha: 0.4)
		}
	}

	/** スクロールバーのハンドル背景色. `.modern`のみと使用 */
	private var handleTintColor: UIColor {
		switch style {
			case .default:
				return .clear
			case .modern:
				return .systemBlue
		}
	}

	/** スクロールバーのハンドルの高さ */
	private var handleHeight: CGFloat {
		guard let scrollView = scrollView else {
			return handleMinimumHeight
		}

		let ratio = scrollView.frame.size.height / scrollView.contentSize.height
		let height = frame.size.height * ratio

		return max(floor(height), handleMinimumHeight)
	}

	/** ユーザーがスクロールバーをドラッグしているかどうか */
	private(set) var isDragging: Bool = false

	// MARK: - Private | 非公開の定数と変数

	private lazy var trackView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleToFill
		view.tintColor = trackTintColor
		view.image = trackImage
		return view
	}()

	private lazy var handleView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleToFill
		view.tintColor = handleTintColor
		view.image = handleImage
		return view
	}()

	private lazy var knobView: UIImageView = {
		let view = UIImageView()
		view.contentMode = .scaleToFill
		view.image = #imageLiteral(resourceName: "shp:scrollKnobImage")
		return view
	}()

	/** 親スクロールビュー（UICollectionView等）*/
	private(set) var scrollView: UIScrollView?

	/** 親スクロールビューの `showsVerticalScrollIndicator`値 */
	private var previousShowsVerticalScrollIndicator: Bool = false

	/** 親スクロールビューの`prefersLargeTitles` 値 */
	private var previousPrefersLargeTitles: Bool = false

	/** ドラッグ開始時のスクロールバーの高さ*/
	private var originalHeight: CGFloat = 0

	/** ドラッグ開始時のスクロールハンドルのYオフセット */
	private var originalYOffset: CGFloat = 0

	/** ドラッグ開始時のスクロールバーの上部の間隔 */
	private var originalTopInset: CGFloat = 0

	/** ハンドルの中部からのオフセット */
	private var offsetFromCenterOfHandle: CGFloat = 0

	/** タッチエリアのHIGサイズ */
	private let totalTapAreaWidth: CGFloat = 44

	// MARK: - KVO

	private var contentSizeObserver: NSKeyValueObservation?
	private var contentOffsetObserver: NSKeyValueObservation?

	// MARK: - Taptic

	/** ユーザーがスクロールバーをドラッグしているのときにTapticフィードバックを提供する
		一部のデバイスが対応されていなく
	 */
	private lazy var feedbackGenerator: UIImpactFeedbackGenerator = {
		UIImpactFeedbackGenerator(style: .light)
	}()

	// MARK: - Gesture

	/** Custom-made gesture recognizer for dragging.
		ドラッグできる為の特注のジェスチャーレコグナイザー
	 */
	private lazy var gesture: BDScrollBarGestureRecognizer = {
		BDScrollBarGestureRecognizer(target: self, action: #selector(handle(_:)), scrollBar: self)
	}()

	// MARK: - Init

	public init(style: BDScrollBarStyle = .default) {
		self.style = style
		super.init(frame: .zero)
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)
	}

	// MARK: - Setup

	private func setup() {
		backgroundColor = .clear

		if !subviews.contains(trackView) {
			addSubview(trackView)
		}

		if !subviews.contains(handleView) {
			addSubview(handleView)
		}

		// スタイルがモダーンならknobを追加しない
		if !handleView.subviews.contains(knobView) && style == .default {
			handleView.addSubview(knobView)
		}

		addGestureRecognizer(gesture)
	}

	open override func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: superview)
		setup()
	}

	// MARK: - Configure View

	private func configure(scrollView: UIScrollView?) {
		guard let scrollView = scrollView else { return }

		// 親スクロールビューの設定されたの値を保存
		previousShowsVerticalScrollIndicator = scrollView.showsVerticalScrollIndicator

		// デフォルトのスクロールバーをオフにして、うちのを使用
		scrollView.showsVerticalScrollIndicator = false

		contentOffsetObserver = scrollView.observe(\.contentOffset, options: .new) { [weak self] _, _ in
			self?.relayoutOnObserverChange()
		}

		contentSizeObserver = scrollView.observe(\.contentSize, options: .new, changeHandler: { [weak self] _, _ in
			self?.relayoutOnObserverChange()
		})
	}

	// MARK: - KVO Funcs

	private func relayoutOnObserverChange() {
		guard let scrollView = scrollView else {
			return
		}

		handleView.isHidden = handleHeight >= scrollView.frame.height
		if handleView.isHidden { return }
		positionSelf()
		setNeedsLayout()
	}

	// MARK: - Restore Old

	private func restore(_ scrollView: UIScrollView?) {
		guard let scrollView = scrollView else {
			return
		}

		// 親スクロールビューのデフォルトを復旧
		scrollView.showsVerticalScrollIndicator = previousShowsVerticalScrollIndicator

		contentSizeObserver = nil
		contentOffsetObserver = nil
	}

	// MARK: - Add To Scroll View

	public func add(to view: UIScrollView) {
		if view == scrollView { return }

		restore(scrollView)
		scrollView = view
		configure(scrollView: view)
		scrollView?.addSubview(self)
		scrollView?.bd_scrollBar = self
		positionSelf()
	}

	// MARK: - Remove

	public func remove() {
		restore(scrollView)
		removeFromSuperview()
		scrollView?.bd_scrollBar = nil
		scrollView = nil
	}

	// MARK: - Layout

	open override func layoutSubviews() {
		let frame = self.frame

		// トラックを追加
		configureTrackFrame()

		// ドラッグならreturn
		if isDragging { return }

		var handleFrame = configurePreliminaryHandleFrame()

		configureKnobFrame(in: handleFrame)

		// インセットがあれば追加
		var insets = scrollView?.contentInset ?? .zero
		insets = scrollView?.safeAreaInsets ?? .zero

		let offset = scrollView?.contentOffset ?? .zero
		let size = scrollView?.contentSize ?? .zero
		let scrollViewFrame = scrollView?.frame ?? .zero
		let totalScrollableHeight = (size.height + insets.top + insets.bottom) - scrollViewFrame.size.height
		let scrollProgress = (offset.y + insets.top) / totalScrollableHeight

		handleFrame.origin.y = (frame.size.height - handleFrame.size.height) * scrollProgress

		// ハンドルサイズを計算
		// Bounceも含む

		if offset.y < -insets.top {
			handleFrame.size.height -= (-offset.y - insets.top)
			handleFrame.size.height = max(handleFrame.size.height, trackWidth * 2)
		} else if (offset.y + scrollViewFrame.size.height > size.height + insets.bottom) {
			let adjusted = offset.y + scrollViewFrame.size.height
			let delta = adjusted - (size.height + insets.bottom)
			handleFrame.size.height -= delta
			handleFrame.size.height = max(handleFrame.size.height, trackWidth * 2)
			handleFrame.origin.y = frame.size.height - handleFrame.size.height
		}

		handleFrame.origin.y = max(handleFrame.origin.y, 0)
		handleFrame.origin.y = min(handleFrame.origin.y, (frame.size.height - handleFrame.size.height))
		handleView.frame = handleFrame
		knobView.frame.origin.y = (handleFrame.size.height / 2) - knobView.bounds.size.height / 2
	}

	func positionSelf() {
		guard let scrollView = scrollView else {
			return
		}

		var largeTitleDelta: CGFloat = 0
		var frame: CGRect = scrollView.frame
		var insets: UIEdgeInsets = scrollView.contentInset
		let offset: CGPoint = scrollView.contentOffset
		let halfWidth: CGFloat = totalTapAreaWidth * 0.5

		insets = scrollView.adjustedContentInset
		frame.size.height -= (insets.top + insets.bottom)
		largeTitleDelta = insetForLargeTitles ? abs(min(insets.top + offset.y, 0)) : 0

		let height = (frame.size.height - (verticalInset.top + verticalInset.bottom)) - largeTitleDelta

		// スクロールバーのフレーム
		var scrollViewFrame = CGRect.zero
		scrollViewFrame.size.width = totalTapAreaWidth
		scrollViewFrame.size.height = (isDragging ? originalHeight : height)
		scrollViewFrame.origin.x = frame.size.width - (edgeInset + halfWidth)
		scrollViewFrame.origin.x -= scrollView.safeAreaInsets.right
		scrollViewFrame.origin.x = min(scrollViewFrame.origin.x, frame.size.width - totalTapAreaWidth)

		if isDragging {
			scrollViewFrame.origin.y = originalYOffset
		} else {
			scrollViewFrame.origin.y = verticalInset.top
			scrollViewFrame.origin.y += insets.top
			scrollViewFrame.origin.y += largeTitleDelta
		}
		scrollViewFrame.origin.y += offset.y
		self.frame = scrollViewFrame

		superview?.bringSubviewToFront(self)
	}

	func setScrollViewOffsetY(for handleOffsetY: CGFloat) {
		guard let scrollView = scrollView else {
			return
		}

		var yOffset = handleOffsetY
		let heightRange = trackView.frame.size.height - handleView.frame.size.height
		yOffset = max(0, yOffset)
		yOffset = min(heightRange, yOffset)

		let positionRatio = yOffset / heightRange
		let frame = scrollView.frame
		var inset = scrollView.contentInset
		let size = scrollView.contentSize

		inset = scrollView.adjustedContentInset
		inset.top = originalTopInset

		let totalScrollSize = (size.height + inset.top + inset.bottom) - frame.size.height
		var scrollOffset = totalScrollSize * positionRatio
		scrollOffset -= inset.top

		var offset = scrollView.contentOffset
		offset.y = scrollOffset

		UIView.animate(withDuration: .leastNormalMagnitude, animations: {
			scrollView.contentOffset = offset
		}, completion: nil)
	}

	// MARK: - Frame Calculation | フレーム計算

	private func configureKnobFrame(in handleFrame: CGRect) {
		var knobFrame = CGRect.zero
		knobFrame.size.width = handleFrame.size.width - 4
		knobFrame.size.height = knobFrame.size.width
		knobFrame.origin.x = 2
		knobFrame.origin.y = (handleFrame.size.height / 2) - knobFrame.size.height / 2
		knobView.frame = knobFrame.integral
	}

	private func configureTrackFrame() {
		var trackFrame = CGRect.zero
		trackFrame.size.width = trackWidth
		trackFrame.size.height = frame.size.height
		trackFrame.origin.x = ceil(frame.size.width - trackWidth - edgeInset)
		trackView.frame = trackFrame.integral
	}

	private func configurePreliminaryHandleFrame() -> CGRect {
		var handleFrame = CGRect.zero
		handleFrame.size.width = handleWidth
		handleFrame.size.height = handleHeight
		handleFrame.origin.x = trackView.frame.midX - (handleWidth / 2)
		return handleFrame.integral
	}

}

// MARK: - Table View Helper Functions | テーブルビューに関する関数

extension BDScrollBar {

	/** UITableViewかUICollectionViewに追加されの場合、separatorInsetを再計算するの必要がある
	 - parameter inset: separatorInsetの既存値
	 */
	func adjustedSeparatorInsets(for insets: UIEdgeInsets) -> UIEdgeInsets {
		var insets = insets
		insets.right = edgeInset * 2
		return insets
	}

	/** UITableViewかUICollectionViewに追加されの場合、cellの内容を左に移動する必要がある
	 - parameter layoutMargins: cellの`layoutMargins`の既存値
	 */
	func adjustedCellLayoutMargins(for layoutMargins: UIEdgeInsets) -> UIEdgeInsets {
		var layoutMargins = layoutMargins
		layoutMargins.right = (edgeInset * 2) + layoutMarginRight
		return layoutMargins
	}

}

// MARK: - Manage Interaction | スクロールバーの相互動作管理

extension BDScrollBar {

	/** ジェスチャー状態を管理 */
	@objc private func handle(_ recognizer: BDScrollBarGestureRecognizer) {
		let point = recognizer.location(in: self)

		switch recognizer.state {
			case .began:
				began(at: point)
			case .changed:
				dragged(to: point)
			case .ended, .cancelled:
				ended()
			default:
				break
		}
	}

	/** ジェスチャーが開始 */
	private func began(at point: CGPoint) {
		// イベントからのフィードバックの遅延を最小限に抑えるためにイベントが生成されようとしていることをTapticジェネレーターに通知
		feedbackGenerator.prepare()

		// ユーザーが制御できるようになったためスクロールビューを一時的に無効にする
		scrollView?.isScrollEnabled = false

		// うちの状態を設定
		isDragging = true

		// 既存の値を保存する
		originalHeight = frame.size.height
		originalYOffset = frame.origin.y - (scrollView?.contentOffset.y ?? 0)
		originalTopInset = scrollView?.adjustedContentInset.top ?? 0

		var handleFrame = handleView.frame

		if (point.y > (handleFrame.origin.y - 20)) && (point.y < handleFrame.origin.y + (handleFrame.size.height + 20)) {
			offsetFromCenterOfHandle = point.y - handleFrame.origin.y
			return
		}

		let maximumYValue = trackView.frame.size.height - handleFrame.height
		let halfHeight = handleFrame.height * 0.5
		var destinationYOffset = point.y - halfHeight
		destinationYOffset = max(0, destinationYOffset)
		destinationYOffset = min(frame.height - halfHeight, destinationYOffset)
		destinationYOffset = min(destinationYOffset, maximumYValue)

		offsetFromCenterOfHandle = point.y - destinationYOffset
		handleFrame.origin.y = destinationYOffset

		// アニメーションでハンドルを移動する
		UIView.animate(
			withDuration: 0.5,
			delay: 0,
			usingSpringWithDamping: 1.0,
			initialSpringVelocity: 0.1,
			options: [.beginFromCurrentState],
			animations: { [weak self] in
				self?.handleView.frame = handleFrame
			},
			completion: nil
		)

		// スクロールビューのオフセットも設定
		setScrollViewOffsetY(for: floor(destinationYOffset))
	}

	/** ジェスチャーの値が変更され */
	private func dragged(to point: CGPoint) {
		var delta: CGFloat = 0
		var handleFrame = handleView.frame
		let trackFrame = trackView.frame
		let minimumYValue = CGFloat(0)
		let maximumYValue = trackFrame.height - handleFrame.height

		delta = handleFrame.origin.y
		handleFrame.origin.y = point.y - offsetFromCenterOfHandle

		if handleFrame.origin.y < minimumYValue {
			offsetFromCenterOfHandle += handleFrame.origin.y
			offsetFromCenterOfHandle = max(minimumYValue, offsetFromCenterOfHandle)
			handleFrame.origin.y = minimumYValue
		} else if handleFrame.origin.y > maximumYValue {
			let overflow = handleFrame.maxY - trackFrame.height
			offsetFromCenterOfHandle += overflow
			offsetFromCenterOfHandle = min(offsetFromCenterOfHandle, handleFrame.height)
			handleFrame.origin.y = min(handleFrame.origin.y, maximumYValue)
		}

		handleView.frame = handleFrame

		delta -= handleFrame.origin.y
		delta = abs(delta)

		if delta > .ulpOfOne && (handleFrame.minY < .ulpOfOne || handleFrame.minY >= maximumYValue - .ulpOfOne) {
			feedbackGenerator.impactOccurred()
		}

		setScrollViewOffsetY(for: floor(handleFrame.origin.y))
	}

	/** タッチが終了 */
	private func ended() {
		// ドラッグが終われ、スクロールビューの相互作用を復旧する
		scrollView?.isScrollEnabled = true

		// 我々はドラッグしていないのを設定
		isDragging = false

		// アニメーションで内容をリセット
		UIView.animate(
			withDuration: 0.5,
			delay: 0,
			usingSpringWithDamping: 1.0,
			initialSpringVelocity: 0.1,
			options: [],
			animations: { [weak self] in
				self?.positionSelf()
				self?.layoutIfNeeded()
			},
			completion: nil
		)
	}

	/** タッチ位置を確認 */
	open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		// タッチの位置を変数に保存
		let result = super.hitTest(point, with: event)

		if isDragging {
			return result
		}

		// タッチ位置がうちのスクロールバーの内にある場合は、スクロールビューを無効にする
		scrollView?.isScrollEnabled = result != self

		return result
	}

}
