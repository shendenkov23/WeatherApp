//
//  CityCell.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import UIKit

class CityCell: UITableViewCell {
  static let identifier = "CityCell"

  var indexPath: IndexPath?
  
  var title: String? {
    didSet {
      lblTitle.text = title
    }
  }

  var distance: String? {
    didSet {
      lblDistance.text = "\(distance ?? "n/a") km"
    }
  }

  var temperature: String? {
    didSet {
      lblTemperature.text = temperature
      activityIndicator.isHidden = temperature != nil
    }
  }
  
  // MARK: - IBOutlets

  @IBOutlet private weak var lblTitle: UILabel!
  @IBOutlet private weak var lblDistance: UILabel!
  @IBOutlet private weak var lblTemperature: UILabel!
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
}
