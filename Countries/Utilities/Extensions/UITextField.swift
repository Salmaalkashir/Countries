//
//  UITextField.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import UIKit

extension UITextField{
  func setView(image: UIImage) {
    var icon = UIImageView()
    icon = UIImageView(frame: CGRect(x: 8, y: 0, width: 25, height: 25))
    icon.image = image.withRenderingMode(.alwaysTemplate)
    icon.tintColor = .gray
    let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 35, height: 25))
    iconContainerView.addSubview(icon)
    leftView = iconContainerView
    leftViewMode = .always
  }
  
  func stylingTextField() {
    layer.cornerRadius = 10
    layer.borderWidth = 0.5
    self.textAlignment = .left
  }
  
  func customizedPlaceholder() {
    let placeholder = placeholder ?? ""
    let placeholderFont = UIFont.systemFont(ofSize: 18)
    let placeholderColor = UIColor.lightGray
    let paragraphStyle = NSMutableParagraphStyle()
    paragraphStyle.headIndent = 10
    let attributes: [NSAttributedString.Key: Any] = [
      .font: placeholderFont,
      .foregroundColor: placeholderColor,
      .paragraphStyle: paragraphStyle
    ]
    self.attributedPlaceholder = NSAttributedString(string: placeholder , attributes: attributes)
  }
}
