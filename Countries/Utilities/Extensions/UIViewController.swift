//
//  UIViewController.swift
//  Countries
//
//  Created by Salma Alkashir on 24/03/2025.
//

import UIKit
extension UIViewController {
  //MARK: - Keyboard
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }
  
  @objc func dismissKeyboard() {
    view.endEditing(true)
  }
  
  func showAlert(on viewController: UIViewController?, title: String, subTitle: String, completion: @escaping ((UIAlertAction)->())) {
    let alert = UIAlertController(title: title,
                                  message: subTitle,
                                  preferredStyle: .alert)
    let okAction = UIAlertAction(title: "No", style: .default, handler: nil)
    let deleteAction = UIAlertAction(title: "Yes", style: .destructive, handler: completion)
    alert.addAction(okAction)
    alert.addAction(deleteAction)
    
    viewController?.present(alert, animated: true, completion: nil)
  }
}
