//
//  WeatherHelper.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import Foundation

private class Geobytes {
  static func url(for latitude: String, _ longitude: String, and radius: Int) -> URL? {
    return URL(string: "http://gd.geobytes.com/GetNearbyCities?callback=?&radius=\(String(radius))&Latitude=\(latitude)&Longitude=\(longitude)&Limit=100")
  }
  
  enum InfoIndex: Int {
    case bearing // The compass bearing in degrees from the nominated city to the nearby city
    case cityName // The name of the nearby city
    case regionCode // The two letter region or state code
    case countryName // The name of the nearby city's country
    case direction // The rough direction rounded to one of the ordinal (or intercardinal) directions
    case nauticalMiles // Distance in Nautical Miles
    case internetCode // The two letter Internet Code of the nearby City's Country
    case kilometres // The distance in Kilometres
    case latitude // The Latitude of the nearby city
    case geobytesLocationCode // The Geobytes Location Code of the nearby city
    case longitude // The Longitude of the nearby city
    case miles // The distance in Miles
    case region // The name of the region or state of the nearby city
  }
}

typealias WeatherHandler = (_ weather: WeatherModel?, _ cell: CityCell, _ indexPath: IndexPath) -> ()

class WeatherHelper {
  
  private let kOpenWeatherMapAppID = <#YOUR OWN OPEN WEATHER MAP APP ID#>
  
  // MARK: -
  
  private var completionHandler: WeatherHandler?
  lazy var getWeatherQueue: OperationQueue = {
    var queue = OperationQueue()
    queue.name = "com.weatherapp.getWeatherQueue"
    queue.qualityOfService = .userInteractive
    return queue
  }()
  

  
  let weatherCache = NSCache<NSString, WeatherModel>()
  
  // MARK: -
  
  static let shared = WeatherHelper()
  private init() {}
  
  // MARK: -
  
  func getWeather(_ latitude: String, longitude: String, cell: CityCell, indexPath: IndexPath, handler: @escaping WeatherHandler) {
    self.completionHandler = handler
    guard let url = weatherUrl(latitude: latitude, longitude: longitude) else {
      return
    }
    
    if let cachedWeather = weatherCache.object(forKey: url.absoluteString as NSString) {
      print("Return cached Weather for \(url)")
      self.completionHandler?(cachedWeather, cell, indexPath)
    } else {
      /* check if there is a download task that is currently downloading the same weather. */
      if let operations = (getWeatherQueue.operations as? [WeatherOperation])?.filter({ $0.url == url && $0.isFinished == false && $0.isExecuting == true }), let operation = operations.first {
        print("Increase the priority for \(url)")
        operation.queuePriority = .veryHigh
      } else {
        /* create a new task to get weather.  */
        print("Create a new task for \(url)")
        let operation = WeatherOperation(url: url, cell: cell, indexPath: indexPath)
        
        operation.handler = { weather, cell, indexPath in
          if let weather = weather {
            self.weatherCache.setObject(weather, forKey: url.absoluteString as NSString)
          }
          self.completionHandler?(weather, cell, indexPath)
        }
        self.getWeatherQueue.addOperation(operation)
      }
    }
  }
  
  func getCities(latitude: String, longitude: String, radius: Int, completion: @escaping ([City]?) -> ()) {
    guard let url = Geobytes.url(for: latitude, longitude, and: radius) else {
      completion(nil)
      return
    }
    
    let task = URLSession.shared.dataTask(with: url) { responseData, _, error in
      guard let responseData = responseData else {
        print("ERROR: ", error?.localizedDescription ?? "")
        return
      }
      
      var responseStr = String(data: responseData, encoding: .utf8)!
      responseStr.removeFirst(2) // Invalid Response from service ( ?(...); )
      responseStr.removeLast(2) // Invalid Response from service
      
      let data = responseStr.data(using: .utf8)!
      do {
        let jsonArray = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String]]
        
        var cities = [City]()
        jsonArray?.forEach { city in
          cities.append(City(title: city[Geobytes.InfoIndex.cityName.rawValue],
                             country: city[Geobytes.InfoIndex.countryName.rawValue],
                             distance: Double(city[Geobytes.InfoIndex.kilometres.rawValue]) ?? 0.0,
                             latitude: city[Geobytes.InfoIndex.latitude.rawValue],
                             longitude: city[Geobytes.InfoIndex.longitude.rawValue]))
        }
        completion(cities)
      } catch let error as NSError {
        print(error)
        completion(nil)
      }
    }
    task.resume()
  }
  
  // MARK: -
  
  private func weatherUrl(latitude: String, longitude: String) -> URL? {
    return URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(kOpenWeatherMapAppID)")
  }
}
