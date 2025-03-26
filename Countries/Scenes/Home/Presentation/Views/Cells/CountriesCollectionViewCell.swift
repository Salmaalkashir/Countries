//
//  CountriesCollectionViewCell.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import UIKit
import SDWebImage


class CountriesCollectionViewCell: UICollectionViewCell {
  @IBOutlet private weak var shadowView: UIView!
  @IBOutlet private weak var countryImage: UIImageView!
  @IBOutlet private weak var countryName: UILabel!
  @IBOutlet private weak var deleteButton: UIButton!
  
  var deleteTapped: (()->())?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    countryImage.layer.cornerRadius = 10
    shadowView.applyShadow(cornerRadius: 10, offsetWidth: 2, offsetHeight: 2, shadowColor: .gray, opacity: 0.3, shadowRadius: 3)
  }
  
  @IBAction func deleteCountry(_ sender: UIButton) {
    deleteTapped?()
  }

  func configureCell(image: String, name: String, indexPath: Int) {
      countryName.text = name
      countryImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"))
      deleteButton.isHidden = (indexPath == 0)
  }

}
