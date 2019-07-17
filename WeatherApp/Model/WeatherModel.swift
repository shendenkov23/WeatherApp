//
//  Weather.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import Foundation

class WeatherModel: Codable {
  let id: Int?
  let name: String?
  let coord: Coord?
  let weather: [Weather]?
  let base: String?
  let main: Main?
  let dt: Int?
  
  struct Coord: Codable {
    let lon: Double?
    let lat: Double?
  }
  
  struct Weather: Codable {
    let id: Int?
    let mail: String?
    let description: String?
    let icon: String?
  }
  
  struct Main: Codable {
    let temp: Double?
    let pressure: Double?
    let humidity: Double?
    let temp_min: Double?
    let temp_max: Double?
    let sea_level: Double?
    let grnd_level: Double?
  }
}
