//
//  CitiesRouter.swift
//  WeatherApp
//
//  Created by iDeveloper on 3/18/19.
//  Copyright © 2019 iDeveloper. All rights reserved.
//

import Foundation

class CitiesRouterImplementation {
  weak var view: CitiesView?
  
  init(view: CitiesView) {
    self.view = view
  }
}

//MARK: - CitiesRouter

extension CitiesRouterImplementation: CitiesRouter {
  
}
