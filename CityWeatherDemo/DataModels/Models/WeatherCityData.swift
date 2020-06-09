//
//  WeatherCityData.swift
//  CityWeatherDemo
//
//  Created by Roger Zhang on 29/5/20.
//  Copyright © 2020 Roger Zhang. All rights reserved.
//

import Foundation

struct WeatherMainData: Codable {
    var temp: Double?
    var tempMin: Double?
    var tempMax: Double?
    var humidity: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
    }

    init() {}
}

struct WeatherDescrData: Codable {
    var id: Int?
    var main: String?
    var description: String?

    init() {}
}

struct WeatherSysData: Codable {
    var type: Int?
    var country: String?
    var sunrise: Int?
    var sunset: Int?

    init() {}
}

struct WeatherWind: Codable {
    var speed: Double?
    var deg: Int?

    init() {}
}

struct LocationCoor: Codable {
    var lon: Double?
    var lat: Double?

    init() {}
}

struct WeatherCityData: Codable {
    var id: Int?
    var coord: LocationCoor?
    var weather: [WeatherDescrData]?
    var main: WeatherMainData?
    var sys: WeatherSysData?
    var wind: WeatherWind?
    var dt: Int?
    var timezone: Int?
    var name: String?

    init() {}
}
