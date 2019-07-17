//
//  LocationHelper.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import Foundation
import CoreLocation



class LocationHelper: NSObject {
  // In seconds
  private let timePeriodOfUpdateLocation: TimeInterval = 20
  // In Meters
  private let distanceFilterOfUpdateLocation: CLLocationDistance = 200
  
  let locationManager = CLLocationManager()
  
  static let shared = LocationHelper()
  
  private var lastUpdateLocation: Date?
  private(set) var currentLocation: CLLocation = CLLocation(latitude: 59.20, longitude: 18.04) {
    didSet {
      lastUpdateLocation = Date()
      reportLocation()
    }
  }
  
  private override init() {
    super.init()
    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    locationManager.distanceFilter = 1
    locationManager.headingFilter = 1
    locationManager.delegate = self
  }
  
  func startTracking() {
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
  }
  
  private func reportLocation() {
    NotificationCenter.default.post(name: .locationDidUpdate, object: nil, userInfo: ["location": currentLocation])
  }
}

//MARK: - CLLocationManagerDelegate
extension LocationHelper: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    
    let distance = location.distance(from: currentLocation)
    
    // Disregarding old and low quality location detections
    let age = location.timestamp.timeIntervalSinceNow
    if (age < -30 || location.horizontalAccuracy > distance || location.horizontalAccuracy < 0) {
      print("[Location] Disregarding location: age: \(age), ha: \(location.horizontalAccuracy) distance: \(distance)")
      return
    }
    
    if let lastUpdate = lastUpdateLocation, lastUpdate.timeIntervalSinceNow > -timePeriodOfUpdateLocation, distance < distanceFilterOfUpdateLocation {
      print("[Location] Disregarding new location. Age: \(lastUpdate.timeIntervalSinceNow). Distance: \(distance)")
      return
    }
    
    currentLocation = location
    locationManager.stopUpdatingLocation()
  }
}

extension NSNotification.Name {
  static let locationDidUpdate = NSNotification.Name("LocationDidUpdate")
}

