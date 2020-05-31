//
//  RootNavigationController.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 29/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import UIKit

class RootNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let rootVC = self.viewControllers.first as? SearchCityWeatherViewController else {
            return
        }
        
        rootVC.viewModel = SearchCityWeatherViewModel(weatherService: WeatherDataService(),
                                                      countryCodeDecoder: CityWeatherHelper(),
                                                      locationService: LocationManager(),
                                                      networkMonitor: NetworkMonitor())
    }

}
