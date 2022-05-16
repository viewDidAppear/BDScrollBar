//
//  UIImage+Color.swift
//  BDScrollBar
//
//  Created by Benjamin Deckys on 2022/05/13.
//

import UIKit

public extension UIImage {
	class func imageFrom(color: UIColor, width: CGFloat) -> UIImage {

		let radius = width * 0.5

		// MARK: - Format

		let rendererFormat = UIGraphicsImageRendererFormat()
		rendererFormat.opaque = false
		rendererFormat.scale = UIScreen.main.scale
		rendererFormat.preferredRange = .automatic

		// MARK: - Render

		let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: width), format: rendererFormat)
		var image = renderer.image { rendererContext in
			color.setFill()
			rendererContext.cgContext.fillEllipse(in: rendererContext.format.bounds)
		}

		// MARK: - Resize

		image = image.resizableImage(withCapInsets: UIEdgeInsets(top: radius, left: radius, bottom: radius, right: radius), resizingMode: .stretch)
		image = image.withRenderingMode(.alwaysTemplate)

		// MARK: - Create

		return image
	}
}
