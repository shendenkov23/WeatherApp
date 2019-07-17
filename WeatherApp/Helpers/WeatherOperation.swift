//
//  WeatherOperation.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import Foundation
import UIKit

class WeatherOperation: Operation {
  var handler: WeatherHandler?
  
  var url: URL
  
  private var cell: CityCell
  private var indexPath: IndexPath
  
  override var isAsynchronous: Bool {
    return true
  }
  
  private var _executing = false {
    willSet {
      willChangeValue(forKey: "isExecuting")
    }
    didSet {
      didChangeValue(forKey: "isExecuting")
    }
  }
  
  override var isExecuting: Bool {
    return _executing
  }
  
  private var _finished = false {
    willSet {
      willChangeValue(forKey: "isFinished")
    }
    
    didSet {
      didChangeValue(forKey: "isFinished")
    }
  }
  
  override var isFinished: Bool {
    return _finished
  }
  
  func executing(_ executing: Bool) {
    _executing = executing
  }
  
  func finish(_ finished: Bool) {
    _finished = finished
  }
  
  required init(url: URL, cell: CityCell, indexPath: IndexPath) {
    self.url = url
    self.cell = cell
    self.indexPath = indexPath
  }
  
    /*override func start() {
        if self.isCancelled {
            finish(true)
        }
       main()
    }*/
  
  override func main() {
    guard isCancelled == false else {
      finish(true)
      return
    }
    executing(true)
    
    getWeather()
  }
  
  private func getWeather() {
    getWeather(with: url) { weather in
      self.handler?(weather, self.cell, self.indexPath)
      self.finish(true)
      self.executing(false)
    }
  }
  
  private func getWeather(with url: URL, completion: @escaping (WeatherModel?) -> ()) {
    let task = URLSession.shared.dataTask(with: url) { responseData, _, error in
      guard let data = responseData else {
        print("ERROR: ", error?.localizedDescription ?? "")
        return
      }
      
      do {
        let weatherModel = try JSONDecoder().decode(WeatherModel.self, from: data)
        completion(weatherModel)
      } catch let error as NSError {
        print(error)
        completion(nil)
      }
    }
    task.resume()
  }
}
