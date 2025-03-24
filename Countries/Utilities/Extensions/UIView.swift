//
//  UIView.swift
//  Countries
//
//  Created by Salma Alkashir on 24/03/2025.
//

import UIKit
extension UIView {
    func applyShadow(cornerRadius: CGFloat, offsetWidth: Int, offsetHeight: Int, shadowColor: UIColor, opacity: Float, shadowRadius: CGFloat)  {
        layer.cornerRadius = cornerRadius
        layer.shadowOffset = CGSize(width: offsetWidth, height: offsetHeight)
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = shadowRadius
    }
}
