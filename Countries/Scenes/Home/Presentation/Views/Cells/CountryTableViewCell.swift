//
//  CountryTableViewCell.swift
//  Countries
//
//  Created by Salma Alkashir on 24/03/2025.
//

import UIKit
import SDWebImage


class CountryTableViewCell: UITableViewCell {
  @IBOutlet private weak var shadowView: UIView!
  @IBOutlet private weak var countryName: UILabel!
  @IBOutlet private weak var countryImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    countryImage.layer.cornerRadius = 10
    shadowView.applyShadow(cornerRadius: 10, offsetWidth: 2, offsetHeight: 2, shadowColor: .gray, opacity: 0.3, shadowRadius: 3)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  func configure(image: String, name: String) {
    countryName.text = name
    countryImage.sd_setImage(with: URL(string: image), placeholderImage: UIImage(named: "placeholder"))
  }
}
