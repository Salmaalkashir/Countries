//
//  HomeViewController.swift
//  Countries
//
//  Created by Salma Alkashir on 23/03/2025.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
  //MARK: - IBOutlets
  @IBOutlet private weak var searchCountriesTextField: UITextField!
  @IBOutlet private weak var addedCountriesCollectionView: UICollectionView!
  @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
  @IBOutlet private weak var countriesTableView: UITableView!
  @IBOutlet private weak var dismissSearchButton: UIButton!
  
  //MARK: - Properties
  private var viewModel: HomeViewModelProtocol
  
  //MARK: - Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    configureViews()
    bindData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    updateUIVisibility()
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
        self?.viewModel.filteredCountries = self?.viewModel.retrievedCountries ?? []
        self?.loadingIndicator.stopAnimating()
        self?.viewModel.myCountryRemote = self?.viewModel.getMyCountry()
        if let country = self?.viewModel.myCountryRemote {
          self?.viewModel.addedCountries.append(country)
        }
        self?.addedCountriesCollectionView.reloadData()
        self?.countriesTableView.reloadData()
      }
    }
    
    viewModel.bindFailure = {  error in
      DispatchQueue.main.async {
        self.loadingIndicator.stopAnimating()
        if error == .internetIssue {
          self.viewModel.isOffline = true
          self.viewModel.myCountryCoreData = self.viewModel.getMyCountryFromCoreData()
          if let country = self.viewModel.myCountryCoreData {
            self.viewModel.coreDataAddedCountries.append(country)
          }
          self.viewModel.filteredCoreDataCountries = self.viewModel.retrieveCountriesFromCoreData()
          self.addedCountriesCollectionView.reloadData()
          self.countriesTableView.reloadData()
        }
        Helpers.showToastMessage(in: self.view, message:"\(error.localizedDescription)", color: .red, x: (self.view.bounds.size.width - 280) / 2, y: self.view.bounds.size.height - 140 - 30, labelHeight: 50, labelWidth: 280, textColor: .white)
      }
    }
  }
  
  //MARK: - Configure Views
  private func configureViews() {
    loadingIndicator.startAnimating()
    setupTableView()
    setupCollectionView()
    setupLocationManager()
    searchCountriesTextField.delegate = self
    searchCountriesTextField.stylingTextField()
    searchCountriesTextField.setView(image: UIImage(systemName: "magnifyingglass") ?? UIImage())
    hideKeyboardWhenTappedAround()
  }
  
  private func setupTableView() {
    let nib = UINib(nibName: "CountryTableViewCell", bundle: nil)
    countriesTableView.register(nib, forCellReuseIdentifier: "country")
    countriesTableView.delegate = self
    countriesTableView.dataSource = self
  }
  
  private func setupCollectionView() {
    let nib = UINib(nibName: "CountriesCollectionViewCell", bundle: nil)
    addedCountriesCollectionView.register(nib, forCellWithReuseIdentifier: "countries")
    addedCountriesCollectionView.delegate = self
    addedCountriesCollectionView.dataSource = self
  }
  
  private func setupLocationManager() {
    LocationManager.shared.onLocationUpdate = { [weak self] coordinates in
      self?.viewModel.fetchCountryCode(from: coordinates)
    }
    
    LocationManager.shared.onAuthorizationChange = { [weak self] status in
      self?.viewModel.handleLocationAuthorization(status: status)
    }
    
    LocationManager.shared.requestLocationPermission()
  }
  
  private func updateUIVisibility() {
    countriesTableView.isHidden = true
    dismissSearchButton.isHidden = true
    addedCountriesCollectionView.isHidden = false
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
    updateUIVisibility()
  }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout  {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.getAddedCountriesCount()
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: "countries", for: indexPath) as! CountriesCollectionViewCell
    let image = viewModel.getCountriesImage(index: indexPath.row)
    let name = viewModel.getCountriesName(index: indexPath.row)
    cell.configureCell(image: image, name: name, indexPath: indexPath.row)
    cell.deleteTapped = { [weak self] in
      self?.showAlert(on: self, title: "Are you sure?", subTitle: "are you sure you want to unpin this country") { _ in
        self?.viewModel.addedCountries.remove(at: indexPath.row)
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
    return viewModel.getCountriesCount() 
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "country", for: indexPath) as! CountryTableViewCell
    let image = viewModel.getFilteredCountriesImage(index: indexPath.row)
    let name = viewModel.getFilteredCountriesName(index: indexPath.row)
    cell.configure(image: image, name: name)
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if viewModel.isOffline == false {
      let country = viewModel.filteredCountries[indexPath.row]
      let countryDetails = UIHostingController(rootView: CountryDetailsView(
        country: country,
        onAddCountry: { [weak self] newCountry in
          if (self?.viewModel.addedCountries.contains(where: { $0.name == newCountry.name }) ?? false) {
            print("Country already added")
          }else {
            if self?.viewModel.addedCountries.count ?? 0 == 5 {
              print("Exceeded Limit")
            }else {
              self?.viewModel.addedCountries.append(newCountry)
              self?.addedCountriesCollectionView.reloadData()
            }
          }
        }
      ))
      navigationController?.pushViewController(countryDetails, animated: true)
    }
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
    
    viewModel.updateFilteredCountries(with: updatedText)
    countriesTableView.reloadData()
    
    return true
  }
}
