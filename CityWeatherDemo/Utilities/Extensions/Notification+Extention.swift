//
//  Notification+Extention.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 30/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

extension Notification.Name {
    static let loadCityList = Notification.Name("CityWeatherDemoLoadCityList")
    static let updateCityWeather = Notification.Name("CityWeatherDemoUpdateCityWeather")
}
