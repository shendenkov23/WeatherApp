//
//  WeatherConfigurator.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import Foundation

class CitiesConfigurator {
  static func configure(_ view: CitiesViewController) {
    let router = CitiesRouterImplementation(view: view)
    let presenter = CitiesPresenterImplementation(view: view, router: router)
    
    view.presenter = presenter
  }
}
