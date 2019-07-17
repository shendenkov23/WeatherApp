//
//  CitiesViewController.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import UIKit

class CitiesViewController: UIViewController {
  var presenter: CitiesPresenter?
  
  // MARK: - IBOutlets

  @IBOutlet private weak var txtRadius: UITextField!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet private weak var tblCities: UITableView!

  // MARK: -

  override func viewDidLoad() {
    super.viewDidLoad()
    CitiesConfigurator.configure(self)
    presenter?.viewDidLoad()
  }

  // MARK: - Actions
  
  @IBAction private func btnSearchPressed(_ sender: UIButton) {
    view.endEditing(true)
    presenter?.searchAction(with: Int(txtRadius.text ?? ""))
  }
}

// MARK: - CitiesView

extension CitiesViewController: CitiesView {
  func showLoader(_ show: Bool) {
    activityIndicator.isHidden = !show
    view.isUserInteractionEnabled = !show
    
    if show {
      UIApplication.shared.beginIgnoringInteractionEvents()
    } else {
      UIApplication.shared.endIgnoringInteractionEvents()
    }
  }
  
  func reloadCities() {
    tblCities.reloadData()
  }
  
  func showRadius(_ radius: Int) {
    txtRadius.text = String(radius)
  }
}

//MARK: - UITableViewDataSource

extension CitiesViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CityCell.identifier, for: indexPath) as! CityCell
    cell.indexPath = indexPath
    presenter?.configure(cell, for: indexPath.row)
    return cell
  }
  
  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    presenter?.getWeather(for: cell as! CityCell, with: indexPath)
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return presenter?.numberOfCities ?? 0
  }
}

//MARK: - UITableViewDelegate

extension CitiesViewController: UITableViewDelegate {
  
}
