//
//  Helpers.swift
//  Countries
//
//  Created by Salma Alkashir on 24/03/2025.
//

import UIKit
class Helpers {
  static func showToastMessage(in view: UIView, message: String, color: UIColor, x: CGFloat, y: CGFloat, labelHeight: CGFloat, labelWidth: CGFloat, textColor: UIColor) {
    let toastLabel = UILabel(frame: CGRect(x: x, y: y, width: labelWidth, height: labelHeight))
    
    toastLabel.textAlignment = .center
    toastLabel.backgroundColor = color
    toastLabel.textColor = textColor
    toastLabel.alpha = 1.0
    toastLabel.font = UIFont(name: "Almarai-Regular", size: 13)
    toastLabel.layer.cornerRadius = 10
    toastLabel.clipsToBounds = true
    toastLabel.text = message
    toastLabel.numberOfLines = 0
    view.addSubview(toastLabel)
    
    let generator = UIImpactFeedbackGenerator(style: .medium)
    generator.impactOccurred()
    
    UIView.animate(withDuration: 3.0, delay: 1.0, options: .curveEaseIn, animations: {
      toastLabel.alpha = 0.0
    }) { _ in
      toastLabel.removeFromSuperview()
    }
  }
}
