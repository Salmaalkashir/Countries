//
//  UIViewController.swift
//  Countries
//
//  Created by Salma Alkashir on 24/03/2025.
//

import UIKit
extension UIViewController {
    //MARK: - Keyboard
    func hideKeyboardWhenTappedAround(vieww: UIView) {
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
      tap.cancelsTouchesInView = false
      view.addGestureRecognizer(tap)
        vieww.isHidden = true
    }
    
    @objc func dismissKeyboard() {
      view.endEditing(true)
    }
}
