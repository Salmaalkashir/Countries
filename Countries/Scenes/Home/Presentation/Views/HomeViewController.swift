//
//  HomeViewController.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import UIKit
import CoreLocation
import SwiftUI

class HomeViewController: UIViewController {
  //MARK: - IBOutlets
  @IBOutlet private weak var searchCountriesTextField: UITextField!
  @IBOutlet private weak var addedCountriesCollectionView: UICollectionView!
  @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet private weak var countriesTableView: UITableView!
  @IBOutlet private weak var dismissSearchButton: UIButton!
  
  //MARK: - Properties
  private let viewModel: HomeViewModel
  private var myCountry: CountryModel? = nil
  private var addedCountries: [CountryModel] = []
  private var filteredCountries: [CountryModel] = []
  
  //MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViews()
    bindData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    countriesTableView.isHidden = true
    dismissSearchButton.isHidden = true
    addedCountriesCollectionView.isHidden = false
  }
  
  //MARK: - Initializer
  init(viewModel: HomeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  //MARK: - Binding
  private func bindData() {
    viewModel.bindCountries = { [weak self] in
      DispatchQueue.main.async {
        self?.filteredCountries = self?.viewModel.retrievedCountries ?? []
        self?.loadingIndicator.stopAnimating()
        self?.myCountry = self?.viewModel.getMyCountry()
        if let country = self?.myCountry {
          self?.addedCountries.append(country)
        }
        self?.addedCountriesCollectionView.reloadData()
        self?.countriesTableView.reloadData()
      }
    }
    
    viewModel.bindFailure = {  error in
      DispatchQueue.main.async {
        self.loadingIndicator.stopAnimating()
        Helpers.showToastMessage(in: self.view, message:"\(error.localizedDescription)", color: .red, x: (self.view.bounds.size.width - 280) / 2, y: self.view.bounds.size.height - 140 - 30, labelHeight: 50, labelWidth: 280, textColor: .white)
      }
    }
  }
  
  //MARK: - Configure Views
  private func configureViews() {
    loadingIndicator.startAnimating()
    searchCountriesTextField.delegate = self
    searchCountriesTextField.stylingTextField()
    searchCountriesTextField.setView(image: UIImage(systemName: "magnifyingglass") ?? UIImage())
    searchCountriesTextField.customizedPlaceholder()
    
    LocationManager.shared.onLocationUpdate = { coordinates in
      LocationManager.shared.getCountryCode(from: coordinates.latitude, longitude: coordinates.longitude) { countryCode in
        if let code = countryCode {
          UserDefaults.standard.set(code, forKey: "countryCode")
          self.viewModel.getCountries()
        } else {
          print("Failed to get country code")
        }
      }
    }
    
    LocationManager.shared.onAuthorizationChange = { status in
      switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        print("Location access authorized")
      case .denied, .restricted:
        print("Location access denied")
        if let countryCode = Locale.current.region?.identifier {
          
          UserDefaults.standard.set(countryCode, forKey: "countryCode")
          self.viewModel.getCountries()
          print("Device Country Code Home: \(countryCode)")
        }
      case .notDetermined:
        print("Location access not determined")
      @unknown default:
        print("Unexpected authorization status")
      }
    }
    LocationManager.shared.requestLocationPermission()
    
    addedCountriesCollectionView.delegate = self
    addedCountriesCollectionView.dataSource = self
    let nib = UINib(nibName: "CountriesCollectionViewCell", bundle: nil)
    addedCountriesCollectionView.register(nib, forCellWithReuseIdentifier: "countries")
    
    let nib1 = UINib(nibName: "CountryTableViewCell", bundle: nil)
    countriesTableView.register(nib1, forCellReuseIdentifier: "country")
    countriesTableView.dataSource = self
    countriesTableView.delegate = self
    countriesTableView.isHidden = true
    dismissSearchButton.isHidden = true
    hideKeyboardWhenTappedAround()
  }
}

//MARK: - IBActions
private extension HomeViewController {
  @IBAction func searchTextFieldTapped(_ sender: UITextField) {
    countriesTableView.isHidden = false
    addedCountriesCollectionView.isHidden = true
    dismissSearchButton.isHidden = false
  }
  
  @IBAction func dismissTapped(_ sender: UIButton) {
    countriesTableView.isHidden = true
    addedCountriesCollectionView.isHidden = false
    dismissSearchButton.isHidden = true
  }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return addedCountries.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "countries", for: indexPath) as! CountriesCollectionViewCell
    cell.configureCell(image: addedCountries[indexPath.row].flags?.png ?? "", name: addedCountries[indexPath.row].name ?? "", indexPath: indexPath.row)
    cell.deleteTapped = { [weak self] in
      self?.showAlert(on: self, title: "Are you sure?", subTitle: "are you sure you want to unpin this country") { _ in
        self?.addedCountries.remove(at: indexPath.row)
        self?.addedCountriesCollectionView.reloadData()
      }
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let numberOfItemsPerRow: CGFloat = 2
    let totalSpacing = (numberOfItemsPerRow - 1) * 8
    let availableWidth = collectionView.bounds.inset(by: collectionView.layoutMargins).width - totalSpacing
    let width = floor(availableWidth / numberOfItemsPerRow)
    let height: CGFloat = 200
    
    return CGSize(width: width, height: height)
  }
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredCountries.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "country", for: indexPath) as! CountryTableViewCell
    cell.configure(image: filteredCountries[indexPath.row].flags?.png ?? "", name: filteredCountries[indexPath.row].name ?? "")
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let country = filteredCountries[indexPath.row]
      let countryDetails = UIHostingController(rootView: CountryDetailsView(
          country: country,
          onAddCountry: { [weak self] newCountry in
            if (self?.addedCountries.contains(where: { $0.name == newCountry.name }) ?? false) {
                print("Country already added")
            }else {
              if self?.addedCountries.count ?? 0 == 5 {
                print("Exceeded Limit")
              }else {
                self?.addedCountries.append(newCountry)
                self?.addedCountriesCollectionView.reloadData()
              }
            }
          }
      ))
      navigationController?.pushViewController(countryDetails, animated: true)
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 90
  }
}

//MARK: - UITextFieldDelegate
extension HomeViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    searchCountriesTextField.resignFirstResponder()
    countriesTableView.isHidden = true
    return true
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let currentText = textField.text ?? ""
    let updatedText = (currentText as NSString).replacingCharacters(in: range, with: string)
    
    filteredCountries.removeAll()
    
    if updatedText.isEmpty {
      filteredCountries = viewModel.retrievedCountries ?? []
    }else {
      for country in viewModel.retrievedCountries ?? [] {
        let name = country.name ?? ""
        if name.uppercased().contains(updatedText.uppercased()) {
          filteredCountries.append(country)
        }
      }
    }
    countriesTableView.reloadData()
    return true
  }
}
