//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import CoreLocation
import Foundation

protocol CitiesView: class {
  func showLoader(_ show: Bool)
  func reloadCities()
  func showRadius(_ radius: Int)
}

protocol CitiesPresenter {
  var numberOfCities: Int { get }
  
  func viewDidLoad()
  func configure(_ cell: CityCell, for index: Int)
  func getWeather(for cell: CityCell, with indexPath: IndexPath)
  func searchAction(with radius: Int?)
}

protocol CitiesRouter {}

// MARK: -

class CitiesPresenterImplementation {
  let router: CitiesRouter
  weak var view: CitiesView?
  
  var cities = [City]()
  
  let defaultRadius = 100
  var currentRadius: Int = 100
  
  // MARK: -
  
  init(view: CitiesView, router: CitiesRouter) {
    self.view = view
    self.router = router
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: -
  
  private func toCelsium(kelvin: Double) -> Double {
    return kelvin - 273.15
  }
  
  private func getCities() {
    let location = LocationHelper.shared.currentLocation
    let latitude = String(location.coordinate.latitude)
    let longitude = String(location.coordinate.longitude)
    let radius = currentRadius
    
    WeatherHelper.shared.getCities(latitude: latitude, longitude: longitude, radius: radius) { [weak self] cities in
      guard let self = self else { return }
      
      if let cities = cities {
        self.cities = cities
      } else {
        print("Some error!")
      }
      
      DispatchQueue.main.async {
        self.view?.reloadCities()
        self.view?.showLoader(false)
      }
    }
  }
  
  @objc private func locationDidUpdate(_ notification: NSNotification) {
    if notification.name == .locationDidUpdate {
      getCities()
    }
  }
}

// MARK: - CitiesPresenter

extension CitiesPresenterImplementation: CitiesPresenter {
  var numberOfCities: Int {
    return cities.count
  }
  
  func viewDidLoad() {
    view?.showLoader(true)
    NotificationCenter.default.addObserver(self, selector: #selector(locationDidUpdate(_:)), name: .locationDidUpdate, object: nil)
    LocationHelper.shared.startTracking()
  }
  
  func configure(_ cell: CityCell, for index: Int) {
    guard cities.count > index else { return }
    let city = cities[index]
    
    cell.title = city.title
    cell.distance = String(city.distance)
  }
  
  func getWeather(for cell: CityCell, with indexPath: IndexPath) {
    guard cities.count > indexPath.row else { return }
    let city = cities[indexPath.row]
    
    cell.temperature = nil
    
    WeatherHelper.shared.getWeather(city.latitude, longitude: city.longitude, cell: cell, indexPath: indexPath) { weather, cell, _indexPath in
      var temperature = "n/a"
      if let temp = weather?.main?.temp {
        let t = Int(self.toCelsium(kelvin: temp))
        temperature = t > 0 ? "+\(t)" : "\(t)"
      }
      
      if _indexPath == cell.indexPath {
        DispatchQueue.main.async {
          cell.temperature = temperature
        }
      }
    }
  }
  
  func searchAction(with radius: Int?) {
    guard radius != currentRadius else { return }
    
    if let radius = radius {
      if radius < 0 || radius > 1000 {
        currentRadius = defaultRadius
      } else {
        currentRadius = radius
      }
    } else {
      currentRadius = defaultRadius
    }
    
    self.view?.showRadius(currentRadius)
    self.view?.showLoader(true)
    getCities()
  }
}
